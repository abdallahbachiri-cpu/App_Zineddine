<?php

namespace App\Controller;

use App\Controller\Abstract\BaseController;
use App\Service\Twilio\TwilioProxyService;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\RouterInterface;

#[Route('/dev', name: 'dev_')]
class DevController extends BaseController
{
    public function __construct(
        private TwilioProxyService $twilioProxyService,
    ) {}
    #[Route('/route-count', name: 'route_count')]
    public function countRoutes(RouterInterface $router): JsonResponse
    {
        $routes = $router->getRouteCollection();
        return new JsonResponse(['route_count' => count($routes)]);
    }

    // #[Route('/twilio/create-session', name: 'twilio_create_session', methods: ['GET'])]
    // #[OA\Get(
    //     summary: "Create a Twilio proxy session",
    //     description: "Creates a new Twilio proxy session for communication between a buyer and seller using their phone numbers.",
    //     tags: ["Dev - Twilio"],
    //     parameters: [
    //         new OA\Parameter(
    //             name: "buyer_phone",
    //             description: "The buyer's phone number in international format",
    //             in: "query",
    //             required: true,
    //             schema: new OA\Schema(type: "string", example: "+1234567890")
    //         ),
    //         new OA\Parameter(
    //             name: "seller_phone",
    //             description: "The seller's phone number in international format",
    //             in: "query",
    //             required: true,
    //             schema: new OA\Schema(type: "string", example: "+0987654321")
    //         )
    //     ],
    //     responses: [
    //         new OA\Response(
    //             response: 200,
    //             description: "Proxy session successfully created",
    //             content: new OA\JsonContent(
    //                 properties: [
    //                     new OA\Property(property: "sessionSid", type: "string", description: "The unique session identifier"),
    //                     new OA\Property(property: "buyerPhoneNumber", type: "string", description: "The assigned proxy number for the buyer"),
    //                     new OA\Property(property: "sellerPhoneNumber", type: "string", description: "The assigned proxy number for the seller")
    //                 ]
    //             )
    //         ),
    //         new OA\Response(
    //             response: 400,
    //             description: "Bad request - Missing or invalid buyer_phone or seller_phone parameters"
    //         ),
    //         new OA\Response(
    //             response: 500,
    //             description: "Server error - Failed to create Twilio proxy session"
    //         )
    //     ]
    // )]
    // public function createTwilioSession(Request $request): JsonResponse
    // {
    //     $buyerPhone = $request->query->get('buyer_phone');
    //     $sellerPhone = $request->query->get('seller_phone');

    //     if (!$buyerPhone || !$sellerPhone) {
    //         return new JsonResponse(['error' => 'Missing buyer_phone or seller_phone parameters'], 400);
    //     }

    //     try {
    //         $result = $this->twilioProxyService->createProxySessionFromNumbers($buyerPhone, $sellerPhone);
    //         return new JsonResponse($result);
    //     } catch (\Exception $e) {
    //         return new JsonResponse(['error' => $e->getMessage()], 500);
    //     }
    // }
}
