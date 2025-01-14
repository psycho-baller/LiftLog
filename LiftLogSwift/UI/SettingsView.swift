//
//  SettingsView.swift
//  LiftLogSwift
//
//  Created by Nathaniel D'Orazio on 2024-11-22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userProfile: UserProfileModel
    @ObservedObject var settings: SettingsStore
    
    // Local view state
    @State private var showEditProfile = false
    @State private var showEditWeight = false
    @State private var showEditGender = false
    @State private var showEditBirthday = false
    @State private var showEditUsername = false
    @State private var showEditPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Profile Image
                    VStack(spacing: 8) {
                        Button(action: {
                            showEditProfile = true
                        }) {
                            if let imageURL = userProfile.imageURL(),
                               let imageData = try? Data(contentsOf: imageURL),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.blue)
                                            .offset(x: 35, y: 35)
                                    )
                            } else {
                                Image("JaneDoe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.blue)
                                            .offset(x: 35, y: 35)
                                    )
                            }
                        }
                        
                        Text(userProfile.name)
                            .font(.title2)
                            .bold()
                    }
                    .padding(.bottom)
                    
                    VStack(spacing: 12) {
                        Text("Settings")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // App Settings
                        ToggleSettingRow(icon: "eye", title: "Profile Public", isOn: $settings.isProfilePublic, isHighlighted: true)
                        ToggleSettingRow(icon: "square.and.arrow.up", title: "Auto Share Workouts", isOn: $settings.autoShareWorkouts, isHighlighted: true)
                        ToggleSettingRow(icon: "bell", title: "Notifications", isOn: $settings.notifications, isHighlighted: true)
                        ToggleSettingRow(icon: "bed.double", title: "Rest Day Reminders", isOn: $settings.restDayReminders, isHighlighted: true)
                        ToggleSettingRow(icon: "drop", title: "Water Intake Reminders", isOn: $settings.waterIntakeReminders, isHighlighted: true)
                        ToggleSettingRow(icon: "bell", title: "Daily Workout Reminders", isOn: $settings.workoutReminders, isHighlighted: true)
                        EditableSettingRow(icon: "dumbbell", title: "Weight", value: settings.weight + " lbs", screenState: $showEditWeight)
                        EditableSettingRow(icon: "person", title: "Gender", value: settings.gender, screenState: $showEditGender)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        Text("Account")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Account Settings
                        EditableSettingRow(icon: "birthday.cake", title: "Birthday", value: settings.birthday, screenState: $showEditBirthday)
                        EditableSettingRow(icon: "person", title: "Username", value: settings.username, screenState: $showEditUsername)
                        EditableSettingRow(icon: "lock", title: "Password", value: settings.password, screenState: $showEditPassword)
                        
                        // Logout Button
                        VStack(spacing: 12) {
                            Button(action: {
                                // Handle logout action
                                // Replace the root view with LaunchView, ensuring no back button
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    window.rootViewController = UIHostingController(rootView: LaunchView())
                                    window.makeKeyAndVisible()
                                }
                            }) {
                                Text("LOGOUT")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [.red, .orange],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        // Update the sheets to pass settings if needed
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(userProfile: userProfile)
        }
        .sheet(isPresented: $showEditWeight) {
            EditWeightView(settings: settings)
        }
        .sheet(isPresented: $showEditGender) {
            EditGenderView(settings: settings)
        }
        .sheet(isPresented: $showEditBirthday) {
            EditBirthdayView(settings: settings)
        }
        .sheet(isPresented: $showEditUsername) {
            EditUsernameView(settings: settings)
        }
        .sheet(isPresented: $showEditPassword) {
            EditPasswordView(settings: settings)
        }
    }
}

struct ToggleSettingRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(title)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.orange)
        }
        .padding()
        .background(isOn ? Color.orange : Color.gray.opacity(0.2))
        .foregroundColor(isOn ? .white : .black)
        .cornerRadius(15)
    }
}

struct EditBirthdayView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings: SettingsStore
    @State private var selectedDate = Date()
    
    // Move the formatter outside the body
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy" // Adjust format as desired
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(15)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Edit Birthday")
                .font(.title)
                .bold()
                .padding()
            
            DatePicker("Select Birthday", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .frame(maxHeight: 400) // Adjust as needed
                .padding()
            
            Button(action: {
                // Save the selected date as a string
                settings.birthday = dateFormatter.string(from: selectedDate)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            
            Spacer()
        }
        .onAppear {
            if let date = dateFormatter.date(from: settings.birthday) {
                selectedDate = date
            } else {
                selectedDate = Date()
            }
        }
    }
}

struct EditGenderView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings: SettingsStore
    
    @State private var selectedGender: String = ""
    let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to specify"]

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(15)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Edit Gender")
                .font(.title)
                .bold()
                .padding()

            Picker("Select your gender", selection: $selectedGender) {
                ForEach(genderOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150) // Adjust as needed
            .onAppear {
                // Pre-select the current gender if it matches one of the options
                if genderOptions.contains(settings.gender) {
                    selectedGender = settings.gender
                } else {
                    // If current setting isn't in the list, choose a default
                    selectedGender = "Prefer not to specify"
                }
            }

            Button(action: {
                settings.gender = selectedGender
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }

            Spacer()
        }
    }
}

struct EditUsernameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings: SettingsStore
    @State private var usernameInput: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(15)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Edit Username")
                .font(.title)
                .bold()
                .padding()

            TextField("Enter your username", text: $usernameInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                settings.username = usernameInput
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            usernameInput = settings.username
        }
    }
}

struct EditPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings: SettingsStore
    
    @State private var passwordInput: String = ""
    @State private var confirmPasswordInput: String = ""
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(15)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Edit Password")
                .font(.title)
                .bold()
                .padding()
            
            // New Password Field
            HStack {
                if isNewPasswordVisible {
                    TextField("Enter your new password", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                } else {
                    SecureField("Enter your new password", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                Button(action: {
                    isNewPasswordVisible.toggle()
                }) {
                    Image(systemName: isNewPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            }
            
            // Confirm Password Field
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Confirm your new password", text: $confirmPasswordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                } else {
                    SecureField("Confirm your new password", text: $confirmPasswordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                Button(action: {
                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            }
            
            // Check if passwords match and are not empty
            let passwordsMatch = !passwordInput.isEmpty && (passwordInput == confirmPasswordInput)
            
            Button(action: {
                // Save only if the passwords match
                if passwordsMatch {
                    settings.password = passwordInput
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(passwordsMatch ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(!passwordsMatch)
            
            Spacer()
        }
    }
}

struct EditableSettingRow: View {
    let icon: String
    let title: String
    let value: String
    @Binding var screenState: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(title)
            Spacer()
            // If the title is "Password", show dots only
            if title == "Password" {
                Text("•••••••••")
                    .foregroundColor(.gray)
            } else {
                Text(value)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                screenState = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    let mockUserProfile = UserProfileModel()
    let mockSettings = SettingsStore()
    SettingsView(userProfile: mockUserProfile, settings: mockSettings)
}
