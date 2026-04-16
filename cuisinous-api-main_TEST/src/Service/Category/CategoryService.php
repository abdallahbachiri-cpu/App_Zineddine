<?php

namespace App\Service\Category;

use App\DTO\CategoryDTO;
use App\Entity\Category;
use App\Entity\Enum\CategoryType;
use App\Exception\ValidationException;
use App\Repository\CategoryRepository;
use App\Helper\PaginationHelper;
use App\Helper\SortingHelper;
use App\Helper\SearchHelper;
use App\Helper\ValidationHelper;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;

class CategoryService
{
    public function __construct(
        private CategoryRepository $categoryRepository,
        private CategoryMapper $categoryMapper,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
    ) {}

    public function getAllCategories(
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder,
        ?string $search = null,
        ?string $type = null
    ): array {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
        
        [$sortBy, $sortOrder] = SortingHelper::validateSorting(
            $sortBy, 
            $sortOrder, 
            Category::ALLOWED_SORT_FIELDS
        );
        
        $search = SearchHelper::validate($search);

        $categories = $this->categoryRepository->findAllWithSearch(
            $search,
            $sortBy,
            $sortOrder,
            $limit,
            $offset,
            $type
        );
        
        $totalCategories = $this->categoryRepository->countWithSearch($search, $type);
        
        $categoriesDTO = $this->categoryMapper->mapToDTOs($categories);

        return PaginationHelper::createPaginatedResponse(
            $page,
            $limit,
            $totalCategories,
            $categoriesDTO
        );
    }

    public function getCategoryById(string $id): Category
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $category = $this->categoryRepository->find($id);
        if (!$category instanceof Category) {
            throw new NotFoundHttpException("Category not found");
        }
        return $category;
    }

    public function getCategoryDTOById(string $id): CategoryDTO
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $category = $this->categoryRepository->find($id);
        if (!$category instanceof Category) {
            throw new NotFoundHttpException("Category not found");
        }
        return $this->categoryMapper->mapToDTO($category);
    }


    public function createCategory(array $data): CategoryDTO
    {
        $constraints = new Assert\Collection([
            'fields' => [
                'type' => [
                    new Assert\NotBlank(),
                    new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 20]),
                    new Assert\Choice([
                        'choices' => CategoryType::values(),
                        'message' => 'The type must be one of: {{ choices }}',
                    ])
                ],
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
            throw new ValidationException($errors);
        }

        // if (empty($data['type']) || empty($data['nameFr']) || empty($data['nameEn'])) {
        //     throw new \InvalidArgumentException('Missing required fields for category creation');
        // }

        $category = new Category();
        $category->setType($data['type'])
                ->setNameFr($data['nameFr'])
                ->setNameEn($data['nameEn']);

        $this->entityManager->persist($category);
        $this->entityManager->flush();

        return $this->categoryMapper->mapToDTO($category);
    }

    public function updateCategory(string $id, array $data): CategoryDTO
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $category = $this->categoryRepository->find($id);
        if (!$category instanceof Category) {
            throw new NotFoundHttpException("Category not found");
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'type' => new Assert\Optional([
                    new Assert\NotBlank(), new Assert\Type('string'),
                    new Assert\Length(['min' => 3, 'max' => 255]),
                    new Assert\Choice([
                        'choices' => CategoryType::values(),
                        'message' => 'The type must be one of: {{ choices }}',
                    ])
                ]),
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
            throw new ValidationException($errors);
        }

        if (isset($data['type'])) {
            $category->setType($data['type']);
        }
        if (isset($data['nameFr'])) {
            $category->setNameFr($data['nameFr']);
        }
        if (isset($data['nameEn'])) {
            $category->setNameEn($data['nameEn']);
        }

        $this->entityManager->flush();

        return $this->categoryMapper->mapToDTO($category);
    }

    public function deleteCategory(string $id): void
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $category = $this->categoryRepository->find($id);
        if (!$category instanceof Category) {
            throw new NotFoundHttpException("Category not found");
        }

        $this->entityManager->remove($category);
        $this->entityManager->flush();
    }

}