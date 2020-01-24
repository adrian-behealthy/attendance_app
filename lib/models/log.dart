class Log {
  final uid;
  final secondSinceEpoch;
  final lat;
  final lng;
  final isIn;
  final projectName;
  final comment;
  final firstName;
  final lastName;

  Log(this.uid, this.secondSinceEpoch, this.lat, this.lng, this.isIn,
      this.projectName, this.comment,
      {this.firstName, this.lastName});
}
