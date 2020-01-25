class Log {
  final uid;
  final secondsSinceEpoch;
  final lat;
  final lng;
  final isIn;
  final projectName;
  final comment;
  final firstName;
  final lastName;

  Log(this.uid, this.secondsSinceEpoch, this.lat, this.lng, this.isIn,
      this.projectName, this.comment,
      {this.firstName, this.lastName});
}
