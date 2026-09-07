import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/shared/presentation/widgets/m3_error_text.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/update_delivery_route_form/update_delivery_route_form_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/update_delivery_route_form/update_delivery_route_form_state.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';

class UpdateDeliveryRoutePage extends StatefulWidget {
  const UpdateDeliveryRoutePage({super.key});

  @override
  State<UpdateDeliveryRoutePage> createState() =>
      _UpdateDeliveryRoutePageState();
}

class _UpdateDeliveryRoutePageState extends State<UpdateDeliveryRoutePage> {
  late TextEditingController _routeNameController;
  late UpdateDeliveryRouteFormCubit _updateDeliveryRouteFormCubit;

  @override
  void dispose() {
    _updateDeliveryRouteFormCubit.close();
    _routeNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDeliveryRouteFormCubit = di<UpdateDeliveryRouteFormCubit>();
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final routeData = extra['DeliveryRouteData'] as DeliveryRouteEntity;
    _routeNameController = TextEditingController(text: routeData.name);
    _updateDeliveryRouteFormCubit.routeNameInputChanged(routeData.name);
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = AppColors.primary;
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final deliveryRouteData = extra['DeliveryRouteData'] as DeliveryRouteEntity;
    final getDeliveryRoutesCubitInDRDP =
        extra['GetDeliveryRoutesCubitInDRDP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDRDP =
        extra['GetDeliveryRoutesUsecaseParamsInDRDP']
            as GetDeliveryRoutesUsecaseParams;

    return BlocProvider<UpdateDeliveryRouteFormCubit>(
      create: (context) => _updateDeliveryRouteFormCubit,
      child:
          BlocConsumer<
            UpdateDeliveryRouteFormCubit,
            UpdateDeliveryRouteFormState
          >(
            listener: (context, state) {
              if (state is UpdateDeliveryRouteFormDone) {
                getDeliveryRoutesCubitInDRDP.call(
                  params: getDeliveryRoutesUsecaseParamsInDRDP,
                );
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.uRPUpdateSuccessTitle.tr(),
                );
              } else if (state is UpdateDeliveryRouteFormFailed) {
                AppDialogUtils.showError(
                  context: context,
                  title: AppStrings.uRPUpdateFailedTitle.tr(),
                  subtitle: AppStrings.uRPUpdateFailedSubtitle.tr(),
                );
              }
            },
            builder: (context, state) => Scaffold(
              backgroundColor: primaryGreen,
              appBar: AppBar(
                backgroundColor: primaryGreen,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  AppStrings.uRPTitle.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: () {
                      context.read<UpdateDeliveryRouteFormCubit>().submit(
                        deliveryRouteData.id,
                      );
                    },
                    child: state is UpdateDeliveryRouteFormLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1.5,
                            ),
                          )
                        : Text(
                            AppStrings.uRPSubmitButtonLabel.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ],
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.uRPRouteInfoLabel.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: AppStrings.uRPRouteNameFieldLabel.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // TextField nhập tên lộ trình
                      Column(
                        children: [
                          TextField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            controller: _routeNameController,
                            onChanged: (value) => context
                                .read<UpdateDeliveryRouteFormCubit>()
                                .routeNameInputChanged(value),
                            decoration: InputDecoration(
                              hintText: AppStrings.uRPRouteNameFieldHintText
                                  .tr(),
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: primaryGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          if (state.routeNameInput.displayError != null)
                            SizedBox(height: 4),

                          if (state.routeNameInput.displayError != null)
                            M3ErrorText(
                              errorText: AppStrings.uRPRouteNameFieldEmptyError
                                  .tr(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
