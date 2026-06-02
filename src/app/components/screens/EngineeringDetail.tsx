import { useNavigate, useParams } from "react-router";
import { ArrowLeft, AlertTriangle, CheckCircle2, BookOpen } from "lucide-react";
import { Button } from "../ui/button";
import { Card } from "../ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../ui/tabs";

export function EngineeringDetail() {
  const navigate = useNavigate();
  const { component } = useParams();

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-4 shadow-lg">
        <div className="flex items-center gap-3">
          <Button
            size="icon"
            variant="ghost"
            className="text-white hover:bg-white/10"
            onClick={() => navigate(-1)}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-xl font-bold">Column Engineering</h1>
            <p className="text-sm text-white/70">Structural Component Detail</p>
          </div>
        </div>
      </div>

      <div className="p-6 space-y-6">
        <Card className="relative overflow-hidden bg-gradient-to-br from-slate-100 to-slate-200 aspect-video">
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="bg-zinc-700 w-32 h-64 rounded-lg shadow-2xl relative">
              <div className="absolute inset-4 border-2 border-dashed border-white/30"></div>
              <div className="absolute top-4 left-4 right-4 h-1 bg-orange"></div>
              <div className="absolute bottom-4 left-4 right-4 h-1 bg-orange"></div>
            </div>
          </div>
        </Card>

        <Tabs defaultValue="purpose" className="w-full">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="purpose">Purpose</TabsTrigger>
            <TabsTrigger value="forces">Forces</TabsTrigger>
            <TabsTrigger value="mistakes">Mistakes</TabsTrigger>
            <TabsTrigger value="checklist">Checklist</TabsTrigger>
          </TabsList>

          <TabsContent value="purpose" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold text-lg mb-3">Engineering Purpose</h3>
              <p className="text-sm text-muted-foreground mb-4">
                Columns are vertical load-bearing members that transfer the weight of the structure from beams and slabs down to the foundation.
              </p>
              <div className="space-y-2 text-sm">
                <p>• Carries axial loads from upper floors</p>
                <p>• Resists lateral forces from wind and seismic activity</p>
                <p>• Provides structural stability and rigidity</p>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="forces" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold text-lg mb-3">Load Transfer & Forces</h3>
              <div className="space-y-3 text-sm">
                <div className="bg-blue-50 p-3 rounded-lg">
                  <p className="font-medium">Compression Force ↓</p>
                  <p className="text-muted-foreground">Primary vertical load from slabs and beams</p>
                </div>
                <div className="bg-orange/10 p-3 rounded-lg">
                  <p className="font-medium">Lateral Force ↔</p>
                  <p className="text-muted-foreground">Wind and seismic loads requiring reinforcement</p>
                </div>
                <div className="bg-purple-50 p-3 rounded-lg">
                  <p className="font-medium">Bending Moment ⟲</p>
                  <p className="text-muted-foreground">Eccentric loads causing bending stress</p>
                </div>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="mistakes" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold text-lg mb-3 flex items-center gap-2">
                <AlertTriangle className="h-5 w-5 text-orange" />
                Common Mistakes
              </h3>
              <ul className="space-y-3 text-sm">
                <li className="flex gap-2">
                  <span className="text-red-600 mt-0.5">✗</span>
                  <span>Insufficient concrete cover (should be 40mm minimum)</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-red-600 mt-0.5">✗</span>
                  <span>Improper rebar spacing and lap length</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-red-600 mt-0.5">✗</span>
                  <span>Missing or inadequate ties/stirrups</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-red-600 mt-0.5">✗</span>
                  <span>Poor quality concrete mix or curing</span>
                </li>
              </ul>
            </Card>
          </TabsContent>

          <TabsContent value="checklist" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold text-lg mb-3 flex items-center gap-2">
                <CheckCircle2 className="h-5 w-5 text-green-600" />
                Inspection Checklist
              </h3>
              <div className="space-y-2">
                {[
                  "Verify column dimensions as per drawings",
                  "Check rebar diameter and grade",
                  "Ensure proper concrete cover with spacers",
                  "Verify tie spacing (150-200mm centers)",
                  "Check formwork alignment and verticality",
                  "Test concrete slump before pouring",
                  "Ensure proper vibration during casting",
                  "Monitor curing for minimum 7 days",
                ].map((item, i) => (
                  <div key={i} className="flex items-start gap-2 text-sm">
                    <input type="checkbox" className="mt-1" />
                    <span>{item}</span>
                  </div>
                ))}
              </div>
            </Card>
          </TabsContent>
        </Tabs>

        <Card className="p-6 bg-slate-50">
          <h3 className="font-bold mb-2 flex items-center gap-2">
            <BookOpen className="h-5 w-5" />
            Code References
          </h3>
          <div className="space-y-1 text-sm text-muted-foreground">
            <p>• BCP SP-07: Building Code of Pakistan</p>
            <p>• ACI 318: Reinforced Concrete Design</p>
            <p>• IS 456: Plain and Reinforced Concrete</p>
          </div>
        </Card>
      </div>
    </div>
  );
}
