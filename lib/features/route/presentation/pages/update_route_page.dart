import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/widgets/m3_error_text.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/route/domain/entities/route_entity.dart';
import 'package:shipgo/features/route/domain/usecases/get_my_routes_usecase.dart';
import 'package:shipgo/features/route/presentation/bloc/get_my_routes/get_my_routes_cubit.dart';
import 'package:shipgo/features/route/presentation/bloc/update_route_form/update_route_form_cubit.dart';
import 'package:shipgo/features/route/presentation/bloc/update_route_form/update_route_form_state.dart';

class UpdateRoutePage extends StatefulWidget {
  const UpdateRoutePage({Key? key}) : super(key: key);

  @override
  State<UpdateRoutePage> createState() => _UpdateRoutePageState();
}

class _UpdateRoutePageState extends State<UpdateRoutePage> {
  late TextEditingController _routeNameController;
  late UpdateMyRouteFormCubit _updateMyRouteFormCubit;

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMyRouteFormCubit = di<UpdateMyRouteFormCubit>();
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final routeData = extra['RouteData'] as RouteEntity;
    _routeNameController = TextEditingController(text: routeData.name);
    _updateMyRouteFormCubit.routeNameInputChanged(routeData.name);
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = AppColors.primary;
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final routeData = extra['RouteData'] as RouteEntity;
    final getMyRoutesCubitInRP =
        extra['GetMyRoutesCubitInRP'] as GetMyRoutesCubit;
    final getMyRoutesUsecaseParamsInRP =
        extra['GetMyRoutesUsecaseParamsInRP'] as GetMyRoutesUsecaseParams;
    final getMyRoutesCubitInRDP =
        extra['GetMyRoutesCubitInRDP'] as GetMyRoutesCubit;
    final getMyRoutesUsecaseParamsInRDP =
        extra['GetMyRoutesUsecaseParamsInRDP'] as GetMyRoutesUsecaseParams;

    return BlocProvider<UpdateMyRouteFormCubit>(
      create: (context) => _updateMyRouteFormCubit,
      child: BlocConsumer<UpdateMyRouteFormCubit, UpdateMyRouteFormState>(
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
                  context.read<UpdateMyRouteFormCubit>().submit(routeData.id);
                },
                child: state is UpdateMyRouteFormLoading
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
                        controller: _routeNameController,
                        onChanged: (value) => context
                            .read<UpdateMyRouteFormCubit>()
                            .routeNameInputChanged(value),
                        decoration: InputDecoration(
                          hintText: AppStrings.uRPRouteNameFieldHintText.tr(),
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
        listener: (context, state) {
          if (state is UpdateMyRouteFormDone) {
            getMyRoutesCubitInRP.call(params: getMyRoutesUsecaseParamsInRP);
            getMyRoutesCubitInRDP.call(params: getMyRoutesUsecaseParamsInRDP);
            context.pop();
          }
        },
      ),
    );
  }
}
