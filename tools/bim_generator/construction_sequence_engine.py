"""13-stage construction sequencing metadata for GLB export."""

from __future__ import annotations

from engine.professional_bim_engine import STAGES_13, sequence_payload_13

APPEAR_END = 0.08
TRAVEL_END = 0.35
ALIGN_END = 0.55
LOWER_END = 0.82


class ConstructionSequenceEngine:
    @staticmethod
    def stages():
        return STAGES_13

    @staticmethod
    def payload(model_id: str, display_name: str, archetype: str):
        return sequence_payload_13(model_id, display_name, archetype)

    @staticmethod
    def phase_for(progress: float) -> str:
        p = max(0.0, min(1.0, progress))
        if p <= APPEAR_END:
            return "appear"
        if p <= TRAVEL_END:
            return "travel"
        if p <= ALIGN_END:
            return "align"
        if p <= LOWER_END:
            return "lower"
        return "snap"
