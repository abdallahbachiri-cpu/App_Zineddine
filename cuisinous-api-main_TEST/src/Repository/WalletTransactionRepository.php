<?php

namespace App\Repository;

use App\Entity\Enum\Wallet\WalletTransactionStatus;
use App\Entity\Enum\Wallet\WalletTransactionType;
use App\Entity\Wallet;
use App\Entity\WalletTransaction;
use App\Helper\MoneyHelper;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\ORM\Query;

/**
 * @extends ServiceEntityRepository<WalletTransaction>
 */
class WalletTransactionRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, WalletTransaction::class);
    }


    public function findLastWithdrawal(Wallet $wallet): ?WalletTransaction
    {
        $qb = $this->createQueryBuilder('t');
        $qb->where('t.wallet = :wallet')
            ->setParameter('wallet', $wallet)
            ->andWhere('t.type = :type')
            ->setParameter('type', WalletTransactionType::WITHDRAWAL->value)
            ->orderBy('t.createdAt', 'DESC')
            ->setMaxResults(1);

        return $qb->getQuery()->getOneOrNullResult();
    }

    public function findByPayoutId(string $payoutId): ?WalletTransaction
    {
        return $this->createQueryBuilder('t')
            ->where('t.stripePayoutId = :payoutId')
            ->setParameter('payoutId', $payoutId)
            ->setMaxResults(1)
            ->getQuery()
            ->getOneOrNullResult();
    }
}
