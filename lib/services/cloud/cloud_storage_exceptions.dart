class CloudStorageException implements Exception {
  //subclass total subset
  const CloudStorageException();
}

class Couldnotcreatenotesexception extends CloudStorageException {
} //inheritance

class Couldnotgetallnotesexception extends CloudStorageException {}

class Couldnotupdatenotesexception extends CloudStorageException {}

class Couldnotdeletenotesexception extends CloudStorageException {}
