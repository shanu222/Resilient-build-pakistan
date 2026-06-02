import { useState } from "react";
import { Search, TrendingUp } from "lucide-react";
import { Input } from "../ui/input";
import { Card } from "../ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../ui/tabs";
import { Badge } from "../ui/badge";
import { Button } from "../ui/button";
import { useNavigate } from "react-router";

export function MaterialsLibrary() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState("");

  const materials = [
    {
      category: "Concrete",
      items: [
        {
          name: "M20 Concrete Mix",
          spec: "20 MPa compressive strength",
          uses: "Columns, beams, slabs",
          life: "50+ years",
          price: "PKR 8,500/m³",
        },
        {
          name: "M25 Concrete Mix",
          spec: "25 MPa compressive strength",
          uses: "Heavy structural elements",
          life: "60+ years",
          price: "PKR 9,200/m³",
        },
      ],
    },
    {
      category: "Steel",
      items: [
        {
          name: "Grade 60 Rebar",
          spec: "60,000 psi yield strength",
          uses: "Primary reinforcement",
          life: "50+ years",
          price: "PKR 285/kg",
        },
        {
          name: "Mild Steel Ties",
          spec: "8mm-12mm diameter",
          uses: "Column/beam stirrups",
          life: "40+ years",
          price: "PKR 265/kg",
        },
      ],
    },
    {
      category: "Bricks",
      items: [
        {
          name: "First Class Bricks",
          spec: "3000 psi strength",
          uses: "Load-bearing walls",
          life: "100+ years",
          price: "PKR 18/piece",
        },
      ],
    },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-4">Materials Library</h1>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-white/50" />
          <Input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search materials..."
            className="pl-10 bg-white/10 border-white/20 text-white placeholder:text-white/50"
          />
        </div>
      </div>

      <div className="p-6 space-y-6">
        <Card className="p-4 bg-gradient-to-r from-green-50 to-green-100 border-green-200">
          <div className="flex items-center gap-3">
            <TrendingUp className="h-5 w-5 text-green-600" />
            <div className="flex-1">
              <p className="font-medium">Live Market Prices</p>
              <p className="text-sm text-muted-foreground">Updated daily from major suppliers</p>
            </div>
            <Button
              size="sm"
              variant="outline"
              onClick={() => navigate("/prices")}
            >
              View Trends
            </Button>
          </div>
        </Card>

        <Tabs defaultValue="concrete" className="w-full">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="concrete">Concrete</TabsTrigger>
            <TabsTrigger value="steel">Steel</TabsTrigger>
            <TabsTrigger value="bricks">Bricks</TabsTrigger>
          </TabsList>

          {materials.map((category) => (
            <TabsContent
              key={category.category.toLowerCase()}
              value={category.category.toLowerCase()}
              className="space-y-3 mt-4"
            >
              {category.items.map((item, index) => (
                <Card key={index} className="p-4">
                  <div className="space-y-3">
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-bold">{item.name}</h3>
                        <p className="text-sm text-muted-foreground">{item.spec}</p>
                      </div>
                      <Badge className="bg-green-600 hover:bg-green-700">
                        {item.price}
                      </Badge>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-sm">
                      <div>
                        <p className="text-muted-foreground">Uses</p>
                        <p className="font-medium">{item.uses}</p>
                      </div>
                      <div>
                        <p className="text-muted-foreground">Expected Life</p>
                        <p className="font-medium">{item.life}</p>
                      </div>
                    </div>
                  </div>
                </Card>
              ))}
            </TabsContent>
          ))}
        </Tabs>
      </div>
    </div>
  );
}
