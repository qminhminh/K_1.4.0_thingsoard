// ignore_for_file: use_key_in_widget_constructors, annotate_overrides

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/auth/noauth/di/noauth_di.dart';
import 'package:thingsboard_app/core/auth/noauth/presentation/bloc/bloc.dart';
import 'package:thingsboard_app/core/auth/noauth/presentation/widgets/noauth_loading_widget.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/locator.dart';

class SwitchEndpointNoAuthView extends TbPageWidget {
  SwitchEndpointNoAuthView({
    required this.tbContext,
    required this.arguments,
  }) : super(tbContext);

  final Map<String, dynamic>? arguments;
  final TbContext tbContext;

  @override
  State<StatefulWidget> createState() => _SwitchEndpointNoAuthViewState();
}

class _SwitchEndpointNoAuthViewState
    extends TbPageState<SwitchEndpointNoAuthView> {
  @override
  Widget build(BuildContext context) {
    if (getIt<NoAuthBloc>().isClosed) {
      return Scaffold(
        body: NoAuthLoadingWidget(tbContext: widget.tbContext),
      );
    }

    return BlocProvider<NoAuthBloc>.value(
      value: getIt()
        ..add(
          SwitchToAnotherEndpointEvent(
            parameters: widget.arguments,
          ),
        ),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<NoAuthBloc, NoAuthState>(
            listener: (context, state) {
              if (state is NoAuthErrorState) {
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    widget.tbContext.pop();
                  }
                });
              } else if (state is NoAuthDoneState) {
                GetIt.instance<NoAuthBloc>().close();
                getIt<ThingsboardAppRouter>().router.navigateTo(
                      context,
                      '/home',
                      replace: true,
                    );
              }
            },
            buildWhen: (_, state) => state is! NoAuthDoneState,
            builder: (context, state) {
              switch (state) {
                case NoAuthLoadingState():
                  return NoAuthLoadingWidget(tbContext: widget.tbContext);

                case NoAuthWipState():
                  return Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      NoAuthLoadingWidget(tbContext: widget.tbContext),
                      Positioned(
                        top: MediaQuery.of(context).size.height / 2 + 80,
                        child: BlocBuilder<NoAuthBloc, NoAuthState>(
                          buildWhen: (_, state) => state is NoAuthWipState,
                          builder: (context, state) {
                            if (state is NoAuthWipState) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 20,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.currentStateMessage,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  );

                case NoAuthErrorState():
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Something went wrong ... Rollback',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );

                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    NoAuthDi.init(tbContext: widget.tbContext);
    super.initState();
  }

  @override
  void dispose() {
    NoAuthDi.dispose();
    super.dispose();
  }
}
