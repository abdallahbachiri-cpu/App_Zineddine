<?php

namespace App\Command;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

#[AsCommand(
    name: 'app:create-support',
    description: 'Creates the default support account (info@cuisinous.ca) if it does not exist'
)]
class CreateSupportCommand extends Command
{
    private const SUPPORT_EMAIL    = 'info@cuisinous.ca';
    private const SUPPORT_PASSWORD = 'Support2024!';

    public function __construct(
        private EntityManagerInterface $em,
        private UserPasswordHasherInterface $passwordHasher,
    ) {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $existing = $this->em->getRepository(User::class)
            ->findOneBy(['email' => self::SUPPORT_EMAIL]);

        if ($existing instanceof User) {
            $io->success(sprintf('Support account already exists: %s', self::SUPPORT_EMAIL));
            return Command::SUCCESS;
        }

        $user = new User();
        $user->setFirstName('Support');
        $user->setLastName('Cuisinous');
        $user->setEmail(self::SUPPORT_EMAIL);
        $user->setType(User::TYPE_SUPPORT);
        $user->setPassword($this->passwordHasher->hashPassword($user, self::SUPPORT_PASSWORD));
        $user->setEmailConfirmed(true);
        $user->setActive(true);
        $user->setLocale('fr');

        $this->em->persist($user);
        $this->em->flush();

        $io->success(sprintf(
            "Support account created:\n  Email    : %s\n  Password : %s\n  Role     : ROLE_SUPPORT",
            self::SUPPORT_EMAIL,
            self::SUPPORT_PASSWORD
        ));

        return Command::SUCCESS;
    }
}
