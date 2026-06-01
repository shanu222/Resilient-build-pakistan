import { useNavigate } from "react-router";
import { useEffect } from "react";
import { motion } from "motion/react";
import { Building2 } from "lucide-react";
import { Button } from "../ui/button";

export function SplashScreen() {
  const navigate = useNavigate();

  return (
    <div className="relative h-full w-full bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#334155] flex flex-col items-center justify-center p-6 overflow-hidden">
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-orange rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-steel rounded-full blur-3xl"></div>
      </div>

      <motion.div
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className="z-10 flex flex-col items-center gap-8"
      >
        <motion.div
          animate={{
            rotateY: [0, 360],
          }}
          transition={{
            duration: 3,
            repeat: Infinity,
            ease: "linear",
          }}
          className="relative"
        >
          <div className="bg-gradient-to-br from-orange to-[#fb923c] p-8 rounded-3xl shadow-2xl">
            <Building2 className="h-24 w-24 text-white" strokeWidth={1.5} />
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.6 }}
          className="text-center"
        >
          <h1 className="text-4xl font-bold text-white mb-2">
            ResilientBuild Pakistan
          </h1>
          <p className="text-lg text-white/80 italic">
            "Choose Location. Build Safe."
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.6 }}
          className="text-center space-y-2"
        >
          <p className="text-white/90">Build Smarter.</p>
          <p className="text-white/90">Build Safer.</p>
          <p className="text-white/90">Build for Pakistan.</p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9, duration: 0.6 }}
          className="mt-8"
        >
          <Button
            size="lg"
            onClick={() => navigate("/onboarding")}
            className="bg-orange hover:bg-orange/90 text-white px-12 py-6 rounded-2xl shadow-xl"
          >
            Get Started
          </Button>
        </motion.div>
      </motion.div>

      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.2, duration: 0.6 }}
        className="absolute bottom-8 text-white/60 text-sm"
      >
        National Resilient Construction Platform
      </motion.div>
    </div>
  );
}
