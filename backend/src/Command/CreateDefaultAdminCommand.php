<?php

namespace App\Command;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[AsCommand(
    name: 'app:create-default-admin',
    description: 'Creates a default admin user if none exists'
)]
class CreateDefaultAdminCommand extends Command
{
    public function __construct(
        private EntityManagerInterface $em,
        private UserPasswordHasherInterface $passwordHasher,
        private ValidatorInterface $validator
    )
    {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $adminExists = $this->em->getRepository(User::class)
            ->count(['type' => User::TYPE_ADMIN]) > 0;

        if ($adminExists) {
            $io->success('Admin user already exists. Skipping creation.');
            return Command::SUCCESS;
        }

        $email = $_ENV['DEFAULT_ADMIN_EMAIL'] ?? 'admin@example.com';
        $password = $_ENV['DEFAULT_ADMIN_PASSWORD'] ?? $this->generateRandomPassword();
        $locale = $_ENV['DEFAULT_ADMIN_LOCALE'] ?? 'en';

        $admin = new User();
        $admin->setFirstName('Admin');
        $admin->setLastName('User');
        $admin->setEmail($email);
        $admin->setType(User::TYPE_ADMIN);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, $password));
        $admin->setEmailConfirmed(true);
        $admin->setActive(true);
        $admin->setLocale($locale);

        $errors = $this->validator->validate($admin);
        if (count($errors) > 0) {
            foreach ($errors as $error) {
                $io->error($error->getPropertyPath().': '.$error->getMessage());
            }
            return Command::FAILURE;
        }

        $this->em->persist($admin);
        $this->em->flush();

        $io->success('Default admin user created successfully!');
        $io->text([
            sprintf('Email: %s', $email),
            // sprintf('Password: %s', $password),
            '',
            "IMPORTANT: It's recommended to change the default password after first login!"
        ]);

        return Command::SUCCESS;
    }

    private function generateRandomPassword(): string
    {
        $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%^&*';
        $password = '';
        for ($i = 0; $i < 12; $i++) {
            $password .= $chars[random_int(0, strlen($chars) - 1)];
        }
        return $password;
    }
}
