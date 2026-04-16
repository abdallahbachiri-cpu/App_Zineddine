import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/verification_request.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/screens/file_upload_screen.dart';
import 'package:cuisinous/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum StoreRequestStatus { pending, approved, rejected }

class StoreVerificationRequestScreen extends StatefulWidget {
  const StoreVerificationRequestScreen({super.key});

  @override
  State<StoreVerificationRequestScreen> createState() =>
      _StoreVerificationRequestScreenState();
}

class _StoreVerificationRequestScreenState
    extends State<StoreVerificationRequestScreen> {
  Future<void>? _fetchRequestFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _fetchRequestFuture =
            context.read<FoodStoreProvider>().getMyStoreRequest();
      });
    }
  }

  Future<void> _navigateAndRefresh() async {
    final didSubmitSuccessfully = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => FileUploadScreen()),
    );

    if (didSubmitSuccessfully == true && mounted) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: FutureBuilder<void>(
          future: _fetchRequestFuture,
          builder: (context, snapshot) {
            return Consumer<FoodStoreProvider>(
              builder: (context, provider, _) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    provider.storeRequest == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.storeRequest == null) {
                  return _buildErrorState(provider.error!);
                }

                if (provider.storeRequest != null) {
                  return RefreshIndicator(
                    onRefresh: _fetchData,
                    child: _buildRequestDetails(provider),
                  );
                } else {
                  return _buildVerificationWelcome();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerificationWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).storeVerificationRequest_welcomeTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).storeVerificationRequest_welcomePrompt,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 50,
              child: CustomButton(
                type: ButtonType.elevated,
                size: ButtonSize.medium,
                shape: ButtonShape.rounded,
                backgroundColor: AppConsts.secondaryAccentColor,
                text: S.of(context).storeVerificationRequest_start,
                onPressed: _navigateAndRefresh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestDetails(FoodStoreProvider provider) {
    final request = provider.storeRequest!;
    final status = StoreRequestStatus.values.firstWhere(
      (e) => e.name == request.status,
      orElse: () => StoreRequestStatus.pending,
    );

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).storeVerificationRequest_status,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatusCard(request),
                      const SizedBox(height: 30),
                      _buildActionButton(status),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: IgnorePointer(
            child: Center(
              child: _SwipeDownIndicator(
                refreshText: S.of(context).storeVerificationRequest_swipeDown,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(StoreRequestStatus status) {
    const ButtonType type = ButtonType.elevated;
    const ButtonSize size = ButtonSize.medium;
    const ButtonShape shape = ButtonShape.rounded;
    const double borderRadius = 10;
    const EdgeInsets padding = EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 24,
    );
    switch (status) {
      case StoreRequestStatus.rejected:
        return CustomButton(
          type: type,
          size: size,
          shape: shape,
          borderRadius: borderRadius,
          padding: padding,
          backgroundColor: Colors.orange,
          onPressed: _navigateAndRefresh,
          text: S.of(context).storeVerificationRequest_rectify,
        );
      case StoreRequestStatus.pending:
      default:
        return CustomButton(
          type: type,
          size: size,
          shape: shape,
          borderRadius: borderRadius,
          padding: padding,
          backgroundColor: AppConsts.accentColor.withAlpha(200),
          onPressed: () {
            context.read<AuthProvider>().logout();
          },
          text: S.of(context).storeVerificationRequest_logout,
        );
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          SizedBox(
            width: 150,
            height: 45,
            child: CustomButton(
              type: ButtonType.elevated,
              shape: ButtonShape.rounded,
              size: ButtonSize.medium,
              backgroundColor: AppConsts.accentColor,
              text: S.of(context).storeVerificationRequest_retry,
              onPressed: _fetchData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(VerificationRequest request) {
    final status = StoreRequestStatus.values.firstWhere(
      (e) => e.name == request.status,
      orElse: () => StoreRequestStatus.pending,
    );
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(status),
            const SizedBox(height: 16),
            _buildDetailItem(S.of(context).storeVerificationRequest_foodStore, [
              request.foodStoreName,
            ]),
            _buildDetailItem(S.of(context).storeVerificationRequest_requestId, [
              request.id,
            ]),
            _buildDetailItem(
              S.of(context).storeVerificationRequest_submittedDoc,
              request.documentIds,
            ),
            if (request.adminComment != null &&
                status == StoreRequestStatus.rejected)
              _buildDetailItem(
                S.of(context).storeVerificationRequest_adminComment,
                [request.adminComment],
              ),
            if (request.verifiedBy != null && request.verifiedAt != null) ...[
              _buildDetailItem(
                S.of(context).storeVerificationRequest_verifiedBy,
                [request.verifiedBy],
              ),
              _buildDetailItem(S.of(context).storeVerificationRequest_date, [
                DateFormat.yMMMd().format(DateTime.parse(request.verifiedAt!)),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(StoreRequestStatus status) {
    Color statusColor;
    IconData statusIcon;
    String statusText = status.name.toUpperCase();
    switch (status) {
      case StoreRequestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case StoreRequestStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        break;
      case StoreRequestStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }
    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 30),
        const SizedBox(width: 10),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: statusColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, List<String?>? values) {
    const double responsiveBreakpoint = 380.0;

    final Widget labelWidget = Text(
      '$label:',
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      overflow: TextOverflow.ellipsis,
    );

    final Widget dataWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          values != null && values.isNotEmpty
              ? values
                  .map(
                    (value) => Text(
                      value ?? '-',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                  .toList()
              : [const Text('-', style: TextStyle(fontSize: 16))],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < responsiveBreakpoint) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelWidget,
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: dataWidget,
                ),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 120, child: labelWidget),
                const SizedBox(width: 8),
                Expanded(child: dataWidget),
              ],
            );
          }
        },
      ),
    );
  }
}

class _SwipeDownIndicator extends StatefulWidget {
  final String refreshText;
  const _SwipeDownIndicator({required this.refreshText});

  @override
  State<_SwipeDownIndicator> createState() => _SwipeDownIndicatorState();
}

class _SwipeDownIndicatorState extends State<_SwipeDownIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 32,
                color: Colors.black.withAlpha(100),
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        Text(
          widget.refreshText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black.withAlpha(100),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
