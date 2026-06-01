#!/usr/bin/env python3
"""Generate all resilient housing BIM GLB assets and deploy to Flutter."""
from engineering_model_generator import EngineeringModelGenerator

if __name__ == "__main__":
    gen = EngineeringModelGenerator()
    gen.generate_all()
    gen.deploy_to_flutter_assets()
    print("Done. Run Flutter app and open any model construction guide.")
