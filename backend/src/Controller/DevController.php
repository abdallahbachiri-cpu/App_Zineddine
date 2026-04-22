<?php

namespace App\Controller;

use App\Controller\Abstract\BaseController;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\RouterInterface;

#[Route('/dev', name: 'dev_')]
class DevController extends BaseController
{
    #[Route('/route-count', name: 'route_count')]
    public function countRoutes(RouterInterface $router): JsonResponse
    {
        $routes = $router->getRouteCollection();
        return new JsonResponse(['route_count' => count($routes)]);
    }
}
