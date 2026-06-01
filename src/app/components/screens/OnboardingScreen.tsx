import { useState } from "react";
import { useNavigate } from "react-router";
import { motion, AnimatePresence } from "motion/react";
import { MapPin, Building2, Shield, ChevronRight } from "lucide-react";
import { Button } from "../ui/button";

const slides = [
  {
    title: "Location-Based Construction Intelligence",
    description: "Select any location in Pakistan and get instant hazard assessments and construction recommendations",
    icon: MapPin,
    color: "from-blue-500 to-cyan-500",
  },
  {
    title: "Engineering Animations",
    description: "Watch interactive 3D models showing exactly how to build resilient structures step by step",
    icon: Building2,
    color: "from-orange to-amber-500",
  },
  {
    title: "Resilience Scoring",
    description: "Understand flood, earthquake, and landslide risks with comprehensive safety assessments",
    icon: Shield,
    color: "from-green-500 to-emerald-500",
  },
];

export function OnboardingScreen() {
  const [currentSlide, setCurrentSlide] = useState(0);
  const navigate = useNavigate();

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      navigate("/home");
    }
  };

  const slide = slides[currentSlide];
  const Icon = slide.icon;

  return (
    <div className="h-full w-full bg-gradient-to-br from-background to-muted flex flex-col">
      <div className="flex-1 flex flex-col items-center justify-center p-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentSlide}
            initial={{ opacity: 0, x: 100 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -100 }}
            transition={{ duration: 0.5 }}
            className="flex flex-col items-center text-center gap-8 max-w-md"
          >
            <motion.div
              initial={{ scale: 0.8 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
              className={`bg-gradient-to-br ${slide.color} p-12 rounded-full shadow-2xl`}
            >
              <Icon className="h-32 w-32 text-white" strokeWidth={1.5} />
            </motion.div>

            <div className="space-y-4">
              <h2 className="text-3xl font-bold text-foreground">
                {slide.title}
              </h2>
              <p className="text-lg text-muted-foreground leading-relaxed">
                {slide.description}
              </p>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      <div className="p-8 space-y-6">
        <div className="flex justify-center gap-2">
          {slides.map((_, index) => (
            <motion.div
              key={index}
              className={`h-2 rounded-full transition-all ${
                index === currentSlide
                  ? "bg-accent w-8"
                  : "bg-muted-foreground/30 w-2"
              }`}
              animate={{
                width: index === currentSlide ? 32 : 8,
              }}
            />
          ))}
        </div>

        <Button
          size="lg"
          onClick={handleNext}
          className="w-full bg-accent hover:bg-accent/90 text-white py-6 rounded-2xl shadow-lg"
        >
          {currentSlide === slides.length - 1 ? "Start Exploring" : "Continue"}
          <ChevronRight className="ml-2 h-5 w-5" />
        </Button>

        <button
          onClick={() => navigate("/home")}
          className="w-full text-muted-foreground hover:text-foreground transition-colors"
        >
          Skip
        </button>
      </div>
    </div>
  );
}
