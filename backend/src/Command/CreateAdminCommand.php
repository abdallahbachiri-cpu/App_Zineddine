<?php

namespace App\Command;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;

/**
 * Creates or resets a named admin account.
 *
 * Usage:
 *   php bin/console app:create-admin
 *   php bin/console app:create-admin --force   # overwrite if already exists
 */
#[AsCommand(
    name: 'app:create-admin',
    description: 'Creates the Cuisinous admin account (abdellah@cuisinous.ca)',
)]
class CreateAdminCommand extends Command
{
    public function __construct(
        private EntityManagerInterface $em,
        private UserPasswordHasherInterface $passwordHasher,
        private ValidatorInterface $validator,
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this->addOption('force', 'f', InputOption::VALUE_NONE, 'Overwrite account if it already exists');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $email     = $_ENV['DEFAULT_ADMIN_EMAIL']    ?? 'abdellah@cuisinous.ca';
        $password  = $_ENV['DEFAULT_ADMIN_PASSWORD'] ?? 'SharedPassword93-';
        $firstName = 'Abdellah';
        $lastName  = 'Admin';
        $locale    = $_ENV['DEFAULT_ADMIN_LOCALE']   ?? 'fr';

        /** @var User|null $existing */
        $existing = $this->em->getRepository(User::class)->findOneBy(['email' => $email]);

        if ($existing !== null && !$input->getOption('force')) {
            $io->warning(sprintf(
                'Admin account <%s> already exists. Use --force to reset the password.',
                $email
            ));
            return Command::SUCCESS;
        }

        $admin = $existing ?? new User();
        $admin->setFirstName($firstName);
        $admin->setLastName($lastName);
        $admin->setEmail($email);
        $admin->setType(User::TYPE_ADMIN);
        $admin->setRoles(['ROLE_ADMIN', 'ROLE_USER']);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, $password));
        $admin->setEmailConfirmed(true);
        $admin->setActive(true);
        $admin->setLocale($locale);

        $errors = $this->validator->validate($admin);
        if (count($errors) > 0) {
            foreach ($errors as $error) {
                $io->error($error->getPropertyPath() . ': ' . $error->getMessage());
            }
            return Command::FAILURE;
        }

        if ($existing === null) {
            $this->em->persist($admin);
        }
        $this->em->flush();

        $io->success(sprintf(
            '%s admin account: %s',
            $existing ? 'Updated' : 'Created',
            $email
        ));
        $io->table(['Field', 'Value'], [
            ['Email',    $email],
            ['Password', $password],
            ['Role',     'ROLE_ADMIN'],
            ['Name',     "$firstName $lastName"],
        ]);
        $io->note('Run: php bin/console app:create-admin --force   to reset the password later.');

        return Command::SUCCESS;
    }
}
