Function tryCatch = (Function fn, Function? onError) async {
  try {
    await fn();
  } catch (e) {
    print('Error: $e');
    if (onError != null) {
      return onError(e);
    }
    return null;
  }
};
