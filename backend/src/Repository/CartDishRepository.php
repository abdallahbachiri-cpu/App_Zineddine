<?php

namespace App\Repository;

use App\Entity\Cart;
use App\Entity\CartDish;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<CartDish>
 */
class CartDishRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, CartDish::class);
    }

    public function findCartDishesWithIngredients(Cart $cart): array
    {
        // return $this->createQueryBuilder('cd')
        //     ->leftJoin('cd.ingredients', 'cdi') // Join ingredients
        //     ->addSelect('cdi') // Ensure ingredients are fetched
        //     ->leftJoin('cdi.dishIngredient', 'di') // Join dish ingredient
        //     ->addSelect('di') // Fetch dish ingredient details
        //     ->where('cd.cart = :cart')
        //     ->setParameter('cart', $cart)
        //     ->getQuery()
        //     ->getResult();

        return $this->createQueryBuilder('cd')
            ->leftJoin('cd.dish', 'd') // Join Dish
            ->addSelect('d') // Fetch Dish details
            ->leftJoin('cd.ingredients', 'cdi') // Join CartDishIngredient
            ->addSelect('cdi') // Fetch CartDishIngredient details
            ->leftJoin('cdi.dishIngredient', 'di') // Join DishIngredient
            ->addSelect('di') // Fetch DishIngredient details
            ->where('cd.cart = :cart')
            ->andWhere('d.available = true') // Ensure Dish is available
            ->andWhere('(cdi.id IS NULL OR (di.available = true AND di.isSupplement = true))') // Ensure ingredient is available & is a supplement
            ->setParameter('cart', $cart)
            ->getQuery()
            ->getResult();
    }


    //    /**
    //     * @return CartDish[] Returns an array of CartDish objects
    //     */
    //    public function findByExampleField($value): array
    //    {
    //        return $this->createQueryBuilder('c')
    //            ->andWhere('c.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->orderBy('c.id', 'ASC')
    //            ->setMaxResults(10)
    //            ->getQuery()
    //            ->getResult()
    //        ;
    //    }

    //    public function findOneBySomeField($value): ?CartDish
    //    {
    //        return $this->createQueryBuilder('c')
    //            ->andWhere('c.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->getQuery()
    //            ->getOneOrNullResult()
    //        ;
    //    }
}
