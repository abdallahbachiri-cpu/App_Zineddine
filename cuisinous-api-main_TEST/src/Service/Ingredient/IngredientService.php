<?php

namespace App\Service\Ingredient;

use App\Entity\FoodStore;
use App\Entity\Ingredient;
use App\Helper\PaginationHelper;
use App\Helper\SearchHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\IngredientRepository;
use App\Service\Ingredient\IngredientMapper;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Validator\Constraints as Assert;

class IngredientService
{
    public function __construct(
        private IngredientRepository $ingredientRepository,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private ValidationHelper $validationHelper,
        private IngredientMapper $ingredientMapper
    ) {}


    public function getAllIngredients(int $page, int $limit, string $sortBy, string $sortOrder, ?string $search = null): array
    {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);

        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, Ingredient::ALLOWED_SORT_FIELDS);

        $search = SearchHelper::validate($search);

        $ingredients = $this->ingredientRepository->findAllWithSearch($search, $sortBy, $sortOrder, $limit, $offset);
        $totalIngredients = $this->ingredientRepository->countWithSearch($search);

        $ingredientsDTO = $this->ingredientMapper->mapToDTOs($ingredients);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalIngredients, $ingredientsDTO);
    }

    public function getIngredientsByFoodStore(
        FoodStore $foodStore,
        int $page = 1,
        int $limit = 50,
        string $sortBy = 'createdAt',
        string $sortOrder = 'DESC',
        ?string $search = null
    ): array
    {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);

        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, Ingredient::ALLOWED_SORT_FIELDS);

        $search = SearchHelper::validate($search);

        $ingredients = $this->ingredientRepository->findByFoodStoreWithSearch(
            $foodStore,
            $search,
            $sortBy,
            $sortOrder,
            $limit,
            $offset
        );
        
        $totalIngredients = $this->ingredientRepository->countByFoodStoreWithSearch($foodStore, $search);

        $ingredientsDTO = $this->ingredientMapper->mapToDTOs($ingredients);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalIngredients, $ingredientsDTO);
    }


    public function getIngredientById(string $id): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }
        $ingredient = $this->ingredientRepository->find($id);
        if (!$ingredient instanceof Ingredient) {
            return new JsonResponse(['error' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $ingredientDTO = $this->ingredientMapper->mapToDTO($ingredient);

        return new JsonResponse($ingredientDTO, JsonResponse::HTTP_OK);
    }

    public function createIngredient(?array $data): JsonResponse
    {
        if ($data === null) {
            return new JsonResponse(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'nameEn' => [new Assert\NotBlank(), new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The name must contain at least one alphabetic character.',
                    ])
                ],
                'nameFr' => [new Assert\NotBlank(), new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The name must contain at least one alphabetic character.',
                    ])
                ],
            ],
            'allowMissingFields' => false,
        ]);
    
        $errors = $this->validator->validate($data, $constraints);
    
        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return new JsonResponse(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = new Ingredient();
        $ingredient->setNameEn($data['nameEn'])
                  ->setNameFr($data['nameFr']);

        $this->entityManager->persist($ingredient);
        $this->entityManager->flush();

        $ingredientDTO = $this->ingredientMapper->mapToDTO($ingredient);
    
        return new JsonResponse($ingredientDTO, JsonResponse::HTTP_CREATED);
    }

    public function updateIngredient(string $id, ?array $data): JsonResponse
    {
        if ($data === null) {
            return new JsonResponse(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (!ValidationHelper::isCorrectUuid($id)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $ingredient = $this->ingredientRepository->find($id);
        if (!$ingredient instanceof Ingredient) {
            return new JsonResponse(['error' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'nameEn' => new Assert\Optional([
                    new Assert\NotBlank(), new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The name must contain at least one alphabetic character.',
                    ])
                ]),
                'nameFr' => new Assert\Optional([
                    new Assert\NotBlank(), new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Regex([
                        'pattern' => '/[a-zA-Z]/',
                        'message' => 'The name must contain at least one alphabetic character.',
                    ])
                ]),
            ],
            'allowMissingFields' => true,
        ]);

        $errors = $this->validator->validate($data, $constraints);
        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return new JsonResponse(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (isset($data['nameEn'])) {
            $ingredient->setNameEn($data['nameEn']);
        }
        if (isset($data['nameFr'])) {
            $ingredient->setNameFr($data['nameFr']);
        }

        $this->entityManager->flush();

        $ingredientDTO = $this->ingredientMapper->mapToDTO($ingredient);

        return new JsonResponse($ingredientDTO, JsonResponse::HTTP_OK);
    }

    public function deleteIngredient(string $id): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }
        $ingredient = $this->ingredientRepository->find($id);
        if (!$ingredient instanceof Ingredient) {
            return new JsonResponse(['error' => 'Ingredient not found.'], JsonResponse::HTTP_NOT_FOUND);
        }

        $this->entityManager->remove($ingredient);
        $this->entityManager->flush();

        return new JsonResponse(null, JsonResponse::HTTP_NO_CONTENT);
    }
}