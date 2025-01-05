import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale("en", LocaleData.EN),
  MapLocale("hi", LocaleData.HI),
];

mixin LocaleData {
  static const String title = "title";
  static const String body = "body";
  static const String hey = "hey";
  static const String empowerWork = "empowerWork";
  static const String yourApplications = "yourApplications";
  static const String viewAll = "viewAll";
  static const String noApplicationsYet = "noApplicationsYet";
  static const String startApplyingNow = "startApplyingNow";
  static const String allJobListings = "allJobListings";
  static const String sortBy = "sortBy";
  static const String profile = "profile";
  static const String name = "name";
  static const String email = "email";
  static const String phone = "phone";
  static const String role = "role";
  static const String saveChanges = "saveChanges";
  static const String location = "location";
  static const String useGeolocation = "useGeolocation";
  static const String notifications = "notifications";
  static const String noNotifications = "noNotifications";
  static const String signUp = "signUp";
  static const String enterFullName = "enterFullName";
  static const String enterEmail = "enterEmail";
  static const String enterPhoneNumber = "enterPhoneNumber";
  static const String enterLocationOrUseGeolocation =
      "enterLocationOrUseGeolocation";
  static const String selectRole = "selectRole";
  static const String enterPassword = "enterPassword";
  static const String confirmPassword = "confirmPassword";
  static const String register = "register";
  static const String or = "or";
  static const String alreadyHaveAccount = "alreadyHaveAccount";
  static const String logIn = "logIn";
  static const String password = "password";
  static const String createJobListing = "createJobListing";
  static const String jobTitle = "jobTitle";
  static const String jobDescription = "jobDescription";
  static const String numWorkers = "numWorkers";
  static const String wagePerDay = "wagePerDay";
  static const String duration = "duration";
  static const String category = "category";
  static const String enterLocation = "enterLocation";
  static const String enableLocationServices = "enableLocationServices";
  static const String locationPermissionDenied = "locationPermissionDenied";
  static const String jobPostedSuccessfully = "jobPostedSuccessfully";
  static const String errorPostingJob = "errorPostingJob";
  static const String postJob = "postJob";
  static const String jobDetails = "jobDetails";
  static const String applications = "applications";
  static const String jobStatus = "jobStatus";
  static const String deleteJob = "deleteJob";
  static const String updateJob = "updateJob";
  static const String errorFetchingJobDetails = "errorFetchingJobDetails";
  static const String jobUpdatedSuccessfully = "jobUpdatedSuccessfully";
  static const String errorUpdatingJob = "errorUpdatingJob";
  static const String jobDeletedSuccessfully = "jobDeletedSuccessfully";
  static const String errorDeletingJob = "errorDeletingJob";
  static const String yourJobListings = "yourJobListings";
  static const String noUserSignedIn = "noUserSignedIn";
  static const String wage = "wage";
  static const String day = "day";
  static const String status = "status";
  static const String profileUpdatedSuccessfully = "profileUpdatedSuccessfully";
  static const String failedToUpdateProfile = "failedToUpdateProfile";
  static const String settings = "settings";
  static const String darkMode = "darkMode";
  static const String errorFetchingWorkerData = "errorFetchingWorkerData";
  static const String ratingSubmittedSuccessfully =
      "ratingSubmittedSuccessfully";
  static const String errorSubmittingRating = "errorSubmittingRating";
  static const String rateEmployer = "rateEmployer";
  static const String rating = "rating";
  static const String cancel = "cancel";
  static const String submit = "submit";
  static const String employerRating = "employerRating";
  static const String reviews = "reviews";
  static const String details = "details";
  static const String days = "days";
  static const String noDescriptionAvailable = "noDescriptionAvailable";
  static const String applied = "applied";
  static const String accepted = "accepted";
  static const String unknown = "unknown";
  static const String applyNow = "applyNow";
  static const String applicationSubmittedSuccessfully =
      "applicationSubmittedSuccessfully";
  static const String errorSubmittingApplication = "errorSubmittingApplication";
  static const String home = "home";
  static const String jobs = "jobs";
  static const String highToLow = "highToLow";
  static const String lowToHigh = "lowToHigh";
  static const String noJobsFound = "noJobsFound";
  static const String onlyEmployersCanViewJobDetails =
      "onlyEmployersCanViewJobDetails";
  static const String userDataNotFound = "userDataNotFound";
  static const String error = "error";
  static const String workerDetails = "workerDetails";
  static const String numRatings = "numRatings";
  static const String avgRating = "avgRating";
  static const String close = "close";
  static const String unknownWorker = "unknownWorker";
  static const String rejected = "rejected";

  static const Map<String, dynamic> EN = {
    title: "Daily Wage App",
    body: "This is a sample application.",
    hey: "Hey, %a!",
    empowerWork: "Empower Work. Simplify Life.",
    yourApplications: "Your Applications.",
    viewAll: "View All",
    noApplicationsYet: "No Applications Yet,",
    startApplyingNow: "Start applying now!",
    allJobListings: "All Job Listings",
    sortBy: "Sort By",
    profile: "Profile",
    name: "Name",
    email: "Email",
    phone: "Phone",
    role: "Role",
    saveChanges: "Save Changes",
    location: "Location",
    useGeolocation: "Use Geolocation",
    notifications: "Notifications",
    signUp: "Sign Up",
    enterFullName: "Enter your full name",
    enterEmail: "Enter your email",
    enterPhoneNumber: "Enter your phone number",
    enterLocationOrUseGeolocation: "Enter location or use geolocation",
    selectRole: "Select your role",
    enterPassword: "Enter your password",
    confirmPassword: "Confirm your password",
    register: "Register",
    or: "OR",
    alreadyHaveAccount: "Already have an account?",
    logIn: "Log In",
    password: "password",
    createJobListing: "Create Job Listing",
    jobTitle: "Job Title",
    jobDescription: "Job Description",
    numWorkers: "Number of Workers",
    wagePerDay: "Wage per Day",
    duration: "Duration (in days)",
    category: "Category",
    enterLocation: "Enter location",
    enableLocationServices: "Please enable location services",
    locationPermissionDenied: "Location permission denied",
    jobPostedSuccessfully: "Job posted successfully",
    errorPostingJob: "Error posting job:",
    postJob: "Post Job",
    jobDetails: "Job Details",
    applications: "Applications",
    jobStatus: "Job Status",
    deleteJob: "Delete Job",
    updateJob: "Update Job",
    errorFetchingJobDetails: "Error fetching job details:",
    jobUpdatedSuccessfully: "Job updated successfully",
    errorUpdatingJob: "Error updating job:",
    jobDeletedSuccessfully: "Job deleted successfully",
    errorDeletingJob: "Error deleting job:",
    yourJobListings: "Your Job Listings",
    noUserSignedIn: "No user is signed in",
    wage: "Wage",
    day: "day",
    status: "Status",
    profileUpdatedSuccessfully: "Profile updated successfully",
    failedToUpdateProfile: "Failed to update profile:",
    settings: "Settings",
    darkMode: "Dark Mode",
    errorFetchingWorkerData: "Error fetching worker data:",
    ratingSubmittedSuccessfully: "Rating submitted successfully",
    errorSubmittingRating: "Error submitting rating:",
    rateEmployer: "Rate Employer",
    rating: "Rating",
    cancel: "Cancel",
    submit: "Submit",
    employerRating: "Employer Rating",
    reviews: "reviews",
    details: "Details",
    days: "days",
    noDescriptionAvailable: "No description available.",
    applied: "Applied",
    accepted: "Accepted",
    unknown: "Unknown",
    applyNow: "Apply Now",
    applicationSubmittedSuccessfully: "Application submitted successfully",
    errorSubmittingApplication: "Error submitting application:",
    home: "Home",
    jobs: "Jobs",
    highToLow: "High to Low",
    lowToHigh: "Low to High",
    noJobsFound: "No jobs found",
    onlyEmployersCanViewJobDetails: "Only employers can view job details.",
    userDataNotFound: "User data not found.",
    error: "Error",
    workerDetails: "Worker Details",
    numRatings: "Number of Ratings",
    avgRating: "Average Rating",
    close: "Close",
    unknownWorker: "Unknown Worker",
    rejected: "Rejected",
  };

  static const Map<String, dynamic> HI = {
    title: "डेली वेज ऐप",
    body: "डेली वेज ऐप",
    hey: "नमस्ते, %a!",
    empowerWork: "काम को सशक्त बनाएं। जीवन को सरल बनाएं।",
    yourApplications: "आपके आवेदन।",
    viewAll: "सभी देखें",
    noApplicationsYet: "अभी तक कोई आवेदन नहीं,",
    startApplyingNow: "अभी आवेदन करना शुरू करें!",
    allJobListings: "सभी नौकरी सूची",
    sortBy: "क्रमबद्ध करें",
    profile: "प्रोफ़ाइल",
    name: "नाम",
    email: "ईमेल",
    phone: "फ़ोन",
    role: "भूमिका",
    saveChanges: "परिवर्तनों को सुरक्षित करें",
    location: "स्थान",
    useGeolocation: "भू-स्थान का उपयोग करें",
    notifications: "सूचनाएं",
    signUp: "साइन अप करें",
    enterFullName: "अपना पूरा नाम दर्ज करें",
    enterEmail: "अपना ईमेल दर्ज करें",
    enterPhoneNumber: "अपना फोन नंबर दर्ज करें",
    enterLocationOrUseGeolocation: "स्थान दर्ज करें या भू-स्थान का उपयोग करें",
    selectRole: "अपनी भूमिका चुनें",
    enterPassword: "अपना पासवर्ड दर्ज करें",
    confirmPassword: "अपना पासवर्ड पुष्टि करें",
    register: "रजिस्टर करें",
    or: "या",
    alreadyHaveAccount: "पहले से ही एक खाता है?",
    logIn: "लॉग इन करें",
    password: "पासवर्ड",
    createJobListing: "नौकरी सूची बनाएँ",
    jobTitle: "नौकरी का शीर्षक",
    jobDescription: "नौकरी का विवरण",
    numWorkers: "कर्मचारियों की संख्या",
    wagePerDay: "प्रति दिन वेतन",
    duration: "अवधि (दिनों में)",
    category: "श्रेणी",
    enterLocation: "स्थान दर्ज करें",
    enableLocationServices: "कृपया स्थान सेवाएं सक्षम करें",
    locationPermissionDenied: "स्थान अनुमति अस्वीकृत",
    jobPostedSuccessfully: "नौकरी सफलतापूर्वक पोस्ट की गई",
    errorPostingJob: "नौकरी पोस्ट करने में त्रुटि:",
    postJob: "नौकरी पोस्ट करें",
    jobDetails: "नौकरी का विवरण",
    applications: "आवेदन",
    jobStatus: "नौकरी की स्थिति",
    deleteJob: "नौकरी हटाएं",
    updateJob: "नौकरी अपडेट करें",
    errorFetchingJobDetails: "नौकरी का विवरण प्राप्त करने में त्रुटि:",
    jobUpdatedSuccessfully: "नौकरी सफलतापूर्वक अपडेट की गई",
    errorUpdatingJob: "नौकरी अपडेट करने में त्रुटि:",
    jobDeletedSuccessfully: "नौकरी सफलतापूर्वक हटाई गई",
    errorDeletingJob: "नौकरी हटाने में त्रुटि:",
    yourJobListings: "आपकी नौकरी सूची",
    noUserSignedIn: "कोई उपयोगकर्ता साइन इन नहीं है",
    wage: "वेतन",
    day: "दिन",
    status: "स्थिति",
    profileUpdatedSuccessfully: "प्रोफ़ाइल सफलतापूर्वक अपडेट की गई",
    failedToUpdateProfile: "प्रोफ़ाइल अपडेट करने में विफल:",
    settings: "सेटिंग्स",
    darkMode: "डार्क मोड",
    errorFetchingWorkerData: "कर्मचारी डेटा प्राप्त करने में त्रुटि:",
    ratingSubmittedSuccessfully: "रेटिंग सफलतापूर्वक सबमिट की गई",
    errorSubmittingRating: "रेटिंग सबमिट करने में त्रुटि:",
    rateEmployer: "नियोक्ता को रेट करें",
    rating: "रेटिंग",
    cancel: "रद्द करें",
    submit: "सबमिट करें",
    employerRating: "नियोक्ता रेटिंग",
    reviews: "समीक्षाएं",
    details: "विवरण",
    days: "दिन",
    noDescriptionAvailable: "कोई विवरण उपलब्ध नहीं है।",
    applied: "लागू किया गया",
    accepted: "स्वीकृत",
    unknown: "अज्ञात",
    applyNow: "अभी आवेदन करें",
    applicationSubmittedSuccessfully: "आवेदन सफलतापूर्वक सबमिट किया गया",
    errorSubmittingApplication: "आवेदन सबमिट करने में त्रुटि:",
    home: "होम",
    jobs: "नौकरियां",
    highToLow: "उच्च से निम्न",
    lowToHigh: "निम्न से उच्च",
    noJobsFound: "कोई नौकरी नहीं मिली",
    onlyEmployersCanViewJobDetails: "केवल नियोक्ता नौकरी विवरण देख सकते हैं।",
    userDataNotFound: "उपयोगकर्ता डेटा नहीं मिला।",
    error: "त्रुटि",
    workerDetails: "कर्मचारी विवरण",
    numRatings: "रेटिंग की संख्या",
    avgRating: "औसत रेटिंग",
    close: "बंद करें",
    unknownWorker: "अज्ञात कर्मचारी",
    rejected: "अस्वीकृत",
  };
}
