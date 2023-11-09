//
//  RootNavigationView.swift
//  Personal Atomic Project
//
//  Created by Sae Pasomba on 21/10/23.
//

import SwiftUI

class viewModel: ObservableObject {
    @Published var myNum = 0
}

class Router: ObservableObject {
    @Published var path = NavigationPath([HomeSteps.view2, HomeSteps.view3])
}

enum HomeSteps: Hashable {
    case view2
    case view3
    case view4
    
    var viewToShow: some View {
        switch self {
        case .view2:
            return AnyView(View2())
        case .view3:
            return AnyView(View3())
        case .view4:
            return AnyView(View4())
        }
    }
}

enum ProfileSteps: Hashable {
    case profile2
    case profile3
    case profile4
    
    var viewToShow: some View {
        switch self {
        case .profile2:
            return AnyView(Profile2())
        case .profile3:
            return AnyView(Profile3())
        case .profile4:
            return AnyView(Profile4())
        }
    }
}

struct RootNavigationView: View {
    enum AppTab: Int, CaseIterable {
        case home
        case profile
        
        var viewToShow: some View {
            switch self {
            case .home:
                return AnyView(View2())
            case .profile:
                return AnyView(Profile2())
            }
        }
        
        var title: String {
            switch self {
            case .home:
                return "Home"
            case .profile:
                return "Profile"
            }
        }
    }
    
    @State var selectedTab: AppTab = .home
    
    @StateObject var path1 = Router()
    
    var body: some View {
        NavigationStack(path: $path1.path) {
            VStack {
                Spacer()
                selectedTab.viewToShow
                Spacer()
                HStack {
                    ForEach(AppTab.allCases, id:\.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text("\(tab.title)")
                        }
                        .buttonStyle(.borderedProminent)
                        
                    }
                }
            }
        }
        .environmentObject(path1)
    }
}

struct View2: View {
    
    @EnvironmentObject var path1: Router
    @StateObject var vm: viewModel = viewModel()
    
    var body: some View {
        VStack {
            Text("Root Home")
            
            NavigationLink {
                View3()
                    .environmentObject(vm)
            } label: {
                Text("Go to View3")
            }

            
//            Button {
//                path1.path.append(HomeSteps.view3)
//            } label: {
//                Text("Go to View3")
//            }
        }
        .navigationDestination(for: HomeSteps.self) { currentStep in
            currentStep.viewToShow
                .environmentObject(vm)
        }
    }
}

struct View3: View {
    @EnvironmentObject var path1: Router
    @EnvironmentObject var vm: viewModel
    
    var body: some View {
        
        Text("\(vm.myNum)")
        
        Button {
            path1.path.append(HomeSteps.view4)
        } label: {
            Text("Go to View4")
        }
        
        NavigationLink {
            View4()
        } label: {
            Text("View4 pake nav link")
        }


    }
}

struct View4: View {
    @EnvironmentObject var path1: Router
    @EnvironmentObject var vm: viewModel
    
    var body: some View {
        Text("Final view for home!")
        Button {
            vm.myNum += 1
        } label: {
            Text("My Num + 1")
        }

        Button {
            path1.path = NavigationPath()
        } label: {
            Text("Back to home!")
        }


    }
}


struct Profile2: View {
    
    @EnvironmentObject var path1: Router
    @StateObject var vm = viewModel()
    
    var body: some View {
        VStack {
            Text("Root Profile")
            
            Button {
                path1.path.append(ProfileSteps.profile3)
            } label: {
                Text("Go to Profile3")
            }
        }
        .navigationDestination(for: ProfileSteps.self) { currentStep in
            currentStep.viewToShow
                .environmentObject(vm)
        }
    }
}

struct Profile3: View {
    @EnvironmentObject var path1: Router
    @EnvironmentObject var vm: viewModel
    
    var body: some View {
        Text("\(vm.myNum)")
        Button {
            path1.path.append(ProfileSteps.profile4)
        } label: {
            Text("Go to Profile4")
        }

    }
}

struct Profile4: View {
    @EnvironmentObject var path1: Router
    @EnvironmentObject var vm: viewModel
    
    var body: some View {
        Button {
            vm.myNum += 1
        } label: {
            Text("My Num + 1")
        }

        Button {
            path1.path = NavigationPath()
        } label: {
            Text("Back to Profile!")
        }

    }
}




struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}
