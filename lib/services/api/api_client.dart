import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/api/api_order.dart';
import '../../models/api/api_responses.dart';

import 'api_config.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: ApiConfig.baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // A. Recommendations & AI
  @POST("/ai/recommend-from-text")
  Future<RecommendationResponse> recommendFromText(@Body() Map<String, dynamic> body);

  // B. Image & 3D Generation
  @POST("/generate-image")
  Future<ImageGenerationResponse> generateImage(@Body() Map<String, dynamic> body);

  @POST("/bouquets/3d-structure")
  Future<ThreeDStructureResponse> get3DStructure(@Body() Map<String, dynamic> body);

  // C. Order Management
  @POST("/orders")
  Future<ApiOrder> createOrder(@Body() Map<String, dynamic> body);

  @GET("/orders/{order_id}")
  Future<ApiOrder> getOrder(@Path("order_id") String orderId);

  @POST("/orders/{order_id}/customer/review")
  Future<ApiOrder> reviewOrder(@Path("order_id") String orderId, @Body() Map<String, String> body);

  @POST("/orders/{order_id}/payment")
  Future<ApiOrder> markOrderAsPaid(@Path("order_id") String orderId);

  // D. Flower Catalog
  @GET("/health")
  Future<void> checkHealth();

  @GET("/catalog/flowers")
  Future<CatalogFlowersResponse> getCatalogFlowers();

  @POST("/bouquets/compose")
  Future<ComposeBouquetResponse> composeBouquet(@Body() Map<String, dynamic> body);
}
