import { TrendingUp, TrendingDown } from "lucide-react";
import { Card } from "../ui/card";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

export function MarketPrices() {
  const priceData = [
    { month: "Jan", cement: 1200, steel: 280, sand: 45 },
    { month: "Feb", cement: 1250, steel: 285, sand: 48 },
    { month: "Mar", cement: 1220, steel: 282, sand: 46 },
    { month: "Apr", cement: 1280, steel: 290, sand: 50 },
    { month: "May", cement: 1300, steel: 295, sand: 52 },
    { month: "Jun", cement: 1320, steel: 300, sand: 53 },
  ];

  const materials = [
    {
      name: "Cement",
      price: "PKR 1,320",
      unit: "per bag (50kg)",
      change: "+8.5%",
      trending: "up",
      color: "text-red-600",
    },
    {
      name: "Steel (Grade 60)",
      price: "PKR 300",
      unit: "per kg",
      change: "+6.2%",
      trending: "up",
      color: "text-red-600",
    },
    {
      name: "Sand (River)",
      price: "PKR 53",
      unit: "per cft",
      change: "+10.4%",
      trending: "up",
      color: "text-red-600",
    },
    {
      name: "Aggregate (20mm)",
      price: "PKR 58",
      unit: "per cft",
      change: "+4.1%",
      trending: "up",
      color: "text-red-600",
    },
    {
      name: "Bricks (First Class)",
      price: "PKR 18",
      unit: "per piece",
      change: "-2.3%",
      trending: "down",
      color: "text-green-600",
    },
    {
      name: "Labor Rate (Mason)",
      price: "PKR 2,500",
      unit: "per day",
      change: "+12.0%",
      trending: "up",
      color: "text-red-600",
    },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-1">Market Prices</h1>
        <p className="text-sm text-white/70">Updated: June 1, 2026</p>
      </div>

      <div className="p-6 space-y-6">
        <Card className="p-6">
          <h3 className="font-bold mb-4">6-Month Price Trend</h3>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={priceData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="month" stroke="#6b7280" fontSize={12} />
              <YAxis stroke="#6b7280" fontSize={12} />
              <Tooltip />
              <Line type="monotone" dataKey="cement" stroke="#ef4444" strokeWidth={2} />
              <Line type="monotone" dataKey="steel" stroke="#f97316" strokeWidth={2} />
              <Line type="monotone" dataKey="sand" stroke="#06b6d4" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
          <div className="flex gap-4 justify-center mt-4 text-xs">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>
              <span>Cement</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-orange rounded-full"></div>
              <span>Steel</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-cyan-500 rounded-full"></div>
              <span>Sand</span>
            </div>
          </div>
        </Card>

        <div>
          <h3 className="font-bold mb-3">Current Rates</h3>
          <div className="space-y-3">
            {materials.map((material, index) => (
              <Card key={index} className="p-4">
                <div className="flex justify-between items-center">
                  <div className="flex-1">
                    <h4 className="font-bold">{material.name}</h4>
                    <p className="text-sm text-muted-foreground">{material.unit}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-bold text-lg">{material.price}</p>
                    <div className={`flex items-center gap-1 justify-end ${material.color} text-sm`}>
                      {material.trending === "up" ? (
                        <TrendingUp className="h-3 w-3" />
                      ) : (
                        <TrendingDown className="h-3 w-3" />
                      )}
                      <span>{material.change}</span>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>

        <Card className="p-6 bg-blue-50 border-blue-200">
          <h3 className="font-bold mb-2">Regional Comparison</h3>
          <p className="text-sm text-muted-foreground">
            Prices shown are averages for Lahore region. Rates may vary in other cities.
          </p>
        </Card>
      </div>
    </div>
  );
}
