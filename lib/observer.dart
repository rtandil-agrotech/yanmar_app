import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  ///We can react to events
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print("an event Happened in $bloc the event is $event");
  }

  ///We can even react to transitions
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    /// With this we can specifically know, when and what changed in our Bloc
    print("There was a transition from ${transition.currentState} to ${transition.nextState}");
  }

  ///We can react to errors, and we will know the error and the StackTrace
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print("Error happened in $bloc with error $error and the stacktrace is $stackTrace");
  }
}
