import { useNavigate, useParams } from "react-router";
import { Waves, CheckCircle, XCircle, ChevronRight } from "lucide-react";
import { Button } from "../ui/button";
import { Card } from "../ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../ui/tabs";
import { Badge } from "../ui/badge";

export function ModelDetails() {
  const navigate = useNavigate();
  const { id } = useParams();

  const modelData = {
    name: "Flood Resilient House",
    resilience: 92,
    hazards: ["Flood", "Heavy Rain", "River Overflow"],
    advantages: [
      "Raised foundation 1.5m above ground level",
      "Water-resistant materials for lower structure",
      "Proper drainage system with sump pump",
      "Elevated electrical and plumbing systems",
      "Reinforced waterproof basement",
    ],
    limitations: [
      "Higher construction cost than standard house",
      "Requires specialized contractors",
      "Ongoing maintenance for drainage system",
      "Not suitable for earthquake-prone zones",
    ],
  };

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="relative h-80 bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center">
        <div className="relative">
          <Waves className="h-40 w-40 text-white" strokeWidth={1} />
          <div className="absolute -bottom-4 -right-4 bg-green-600 rounded-full p-3">
            <span className="text-white font-bold text-lg">92%</span>
          </div>
        </div>
      </div>

      <div className="p-6 -mt-10 relative z-10 space-y-6">
        <Card className="p-6 shadow-xl">
          <h1 className="text-2xl font-bold mb-2">{modelData.name}</h1>
          <div className="flex flex-wrap gap-2 mb-4">
            {modelData.hazards.map((hazard, i) => (
              <Badge key={i} variant="secondary">
                {hazard}
              </Badge>
            ))}
          </div>
          <div className="flex items-center gap-2 text-green-600">
            <div className="bg-green-100 px-3 py-1 rounded-full">
              <span className="font-bold">Resilience Score: {modelData.resilience}%</span>
            </div>
          </div>
        </Card>

        <Tabs defaultValue="overview" className="w-full">
          <TabsList className="grid w-full grid-cols-5">
            <TabsTrigger value="overview" className="text-xs">Overview</TabsTrigger>
            <TabsTrigger value="engineering" className="text-xs">Engineering</TabsTrigger>
            <TabsTrigger value="materials" className="text-xs">Materials</TabsTrigger>
            <TabsTrigger value="construction" className="text-xs">Build</TabsTrigger>
            <TabsTrigger value="downloads" className="text-xs">Files</TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold text-lg mb-4 flex items-center gap-2">
                <CheckCircle className="h-5 w-5 text-green-600" />
                Advantages
              </h3>
              <ul className="space-y-2">
                {modelData.advantages.map((advantage, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm">
                    <span className="text-green-600 mt-0.5">✓</span>
                    <span>{advantage}</span>
                  </li>
                ))}
              </ul>
            </Card>

            <Card className="p-6">
              <h3 className="font-bold text-lg mb-4 flex items-center gap-2">
                <XCircle className="h-5 w-5 text-orange" />
                Limitations
              </h3>
              <ul className="space-y-2">
                {modelData.limitations.map((limitation, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm">
                    <span className="text-orange mt-0.5">!</span>
                    <span>{limitation}</span>
                  </li>
                ))}
              </ul>
            </Card>
          </TabsContent>

          <TabsContent value="engineering" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold mb-3">Engineering Principles</h3>
              <div className="space-y-3 text-sm text-muted-foreground">
                <p>• Raised plinth design prevents water ingress</p>
                <p>• Reinforced concrete foundation with waterproofing</p>
                <p>• Load distribution optimized for elevated structure</p>
                <p>• Integrated drainage with automatic pumping</p>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="materials" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold mb-3">Key Materials</h3>
              <div className="space-y-2 text-sm">
                <p>• Waterproof concrete mix (M20 grade)</p>
                <p>• Galvanized steel reinforcement</p>
                <p>• Water-resistant bricks for foundation</p>
                <p>• Bitumen waterproofing membrane</p>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="construction" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold mb-3">Construction Phases</h3>
              <div className="space-y-2 text-sm">
                <p>1. Site survey and elevation planning</p>
                <p>2. Excavation and foundation work</p>
                <p>3. Waterproofing and drainage installation</p>
                <p>4. Raised plinth construction</p>
                <p>5. Structural frame and finishing</p>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="downloads" className="space-y-4 mt-4">
            <Card className="p-6">
              <h3 className="font-bold mb-3">Available Downloads</h3>
              <div className="space-y-2 text-sm">
                <Button variant="outline" className="w-full justify-start">
                  Construction Guidelines PDF
                </Button>
                <Button variant="outline" className="w-full justify-start">
                  Structural Drawings DWG
                </Button>
                <Button variant="outline" className="w-full justify-start">
                  BOQ Excel Template
                </Button>
              </div>
            </Card>
          </TabsContent>
        </Tabs>

        <Button
          onClick={() => navigate(`/construction/${id}`)}
          className="w-full bg-accent hover:bg-accent/90 text-white py-6 rounded-2xl shadow-lg"
          size="lg"
        >
          Start Construction Guide
          <ChevronRight className="ml-2 h-5 w-5" />
        </Button>
      </div>
    </div>
  );
}
