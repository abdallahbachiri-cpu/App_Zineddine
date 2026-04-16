<?php

namespace App\Controller\Api\V2;

use App\Controller\Abstract\BaseController;
use App\DTO\UserDTO;
use App\Entity\User;
use App\Service\User\UserService;
use App\Service\User\UserMapper;
use App\Exception\ValidationException;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use DomainException;
use InvalidArgumentException;

#[Route('/api/v2/seller', name: 'v2_seller_')]
class SellerController extends BaseController
{
    public function __construct(
        private UserService $userService,
        private UserMapper $userMapper
    ) {}

    #[Route('', name: 'info', methods: ['GET'])]
    #[OA\Get(
        summary: "Get the logged-in seller's information (v2)",
        tags: ["Seller v2"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response",
                content: new OA\JsonContent(ref: "#/components/schemas/UserDTO")
            )
        ]
    )]
    public function getSellerInfo(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        return $this->json($this->userMapper->mapToDTO($user));
    }

    #[Route('', name: 'update', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update the logged-in seller's profile (v2)",
        description: "Updates seller profile and FCM token for push notifications.",
        tags: ["Seller v2"],
        requestBody: new OA\RequestBody(
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "fcm_token", type: "string", nullable: true),
                    new OA\Property(property: "firstName", type: "string", nullable: true),
                    new OA\Property(property: "lastName", type: "string", nullable: true),
                    new OA\Property(property: "email", type: "string", format: "email", nullable: true),
                    new OA\Property(property: "phoneNumber", type: "string", nullable: true)
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: "Profile updated"),
            new OA\Response(response: 400, description: "Bad request")
        ]
    )]
    public function updateSeller(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        try {
            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], Response::HTTP_BAD_REQUEST);
            }

            return $this->userService->updateUser($user->getId(), $data);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred.'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
