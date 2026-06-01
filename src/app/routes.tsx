import { createBrowserRouter } from "react-router";
import { RootLayout } from "./components/layouts/RootLayout";
import { SplashScreen } from "./components/screens/SplashScreen";
import { OnboardingScreen } from "./components/screens/OnboardingScreen";
import { HomeDashboard } from "./components/screens/HomeDashboard";
import { LocationAnalysis } from "./components/screens/LocationAnalysis";
import { RecommendedModels } from "./components/screens/RecommendedModels";
import { ModelDetails } from "./components/screens/ModelDetails";
import { ConstructionGuide } from "./components/screens/ConstructionGuide";
import { EngineeringDetail } from "./components/screens/EngineeringDetail";
import { MaterialsLibrary } from "./components/screens/MaterialsLibrary";
import { MarketPrices } from "./components/screens/MarketPrices";
import { DownloadCenter } from "./components/screens/DownloadCenter";
import { ConstructionAcademy } from "./components/screens/ConstructionAcademy";
import { AIInspection } from "./components/screens/AIInspection";
import { ProjectTracker } from "./components/screens/ProjectTracker";
import { ResilienceReport } from "./components/screens/ResilienceReport";
import { ProfileScreen } from "./components/screens/ProfileScreen";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: RootLayout,
    children: [
      { index: true, Component: SplashScreen },
      { path: "onboarding", Component: OnboardingScreen },
      { path: "home", Component: HomeDashboard },
      { path: "location/:id", Component: LocationAnalysis },
      { path: "models", Component: RecommendedModels },
      { path: "model/:id", Component: ModelDetails },
      { path: "construction/:id", Component: ConstructionGuide },
      { path: "engineering/:component", Component: EngineeringDetail },
      { path: "materials", Component: MaterialsLibrary },
      { path: "prices", Component: MarketPrices },
      { path: "downloads", Component: DownloadCenter },
      { path: "academy", Component: ConstructionAcademy },
      { path: "inspection", Component: AIInspection },
      { path: "projects", Component: ProjectTracker },
      { path: "report/:id", Component: ResilienceReport },
      { path: "profile", Component: ProfileScreen },
    ],
  },
]);
