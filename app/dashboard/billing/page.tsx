"use client";
import { motion } from "framer-motion";
import { Sparkles, Zap, Check } from "lucide-react";
import { useState } from "react";
import { PayPalButtons } from "@paypal/react-paypal-js";
import { useRouter } from 'next/navigation';


const plans = [
    {
        credits: 20,
        price: 0.5,
        popular: false,
        features: [
            "20 AI Room Transformations",
            "Basic Support",
            "Standard Processing"
        ]
    },
    {
        credits: 50,
        price: 1,
        popular: true,
        features: [
            "50 AI Room Transformations",
            "Priority Support",
            "Fast Processing",
            "HD Quality"
        ]
    },
    {
        credits: 120,
        price: 2,
        popular: false,
        features: [
            "120 AI Room Transformations",
            "Premium Support",
            "Ultra-Fast Processing",
            "4K Quality",
            "Advanced Customization"
        ]
    },
    {
        credits: 250,
        price: 3,
        popular: false,
        features: [
            "250 AI Room Transformations",
            "24/7 VIP Support",
            "Instant Processing",
            "8K Quality",
            "Advanced Customization",
            "Priority Queue"
        ]
    }
];

export default function BillingPage() {
    const router = useRouter();
    //const { userDetails, setUserDetails } = useUserDetails();
    const [selectedPlan, setSelectedPlan] = useState<{credits: number, price: number} | null>(null);
    const [isProcessing, setIsProcessing] = useState(false);

    const handlePlanSelect = (credits: number, price: number) => {
        setSelectedPlan({ credits, price });
    };

    // const handleApprove = async (data: OnApproveData, actions: OnApproveActions) => {
    //     try {
    //         setIsProcessing(true);
    //         if (!actions?.order) return;

    //         const response = await axios.post(`/api/orders/${data.orderID}/capture`, {
    //             orderId: data.orderID
    //         });
            
    //         if (response.status === 200) {
    //             await fetch('/api/add-credits', {
    //                 method: 'POST',
    //                 headers: { 'Content-Type': 'application/json' },
    //                 body: JSON.stringify({
    //                     email: userDetails.email,
    //                     credits: selectedPlan?.credits
    //                 })
    //             });

    //             setUserDetails({
    //                 ...userDetails,
    //                 credits: userDetails.credits + (selectedPlan?.credits || 0)
    //             });

    //             router.push('/dashboard?success=true');
    //         }
    //     } catch (error) {
    //         console.error('Payment processing error:', error);
    //     } finally {
    //         setIsProcessing(false);
    //     }
    // };

    // const handleCancel = () => {
    //     console.log("Cancelled");
    // };

    const createOrder =
    (data: any, actions: any) => {
        return actions.order
            .create({
                purchase_units: [
                    {
                        description: "Product Description",
                        amount: {
                            currency_code: "USD",
                            value: selectedPlan?.price.toFixed(2).toString() || "0",
                        },
                    },
                ],
            })
            .then((orderID: any) => {
                return orderID;
            });
    }

// const onPayPalSubmit: any = async () => {
//     try {
//         const response = await recordPaymentService({
//             amount: 100,
//         })
//     } catch (err) {
//         console.log('onPayPalSubmit', err)
//     }
// }

const onApprove = (data: any, actions: any) => {
    return actions.order.capture().then(function (details: any) {
        const { payer } = details;
        console.log(payer);
        //*perform db operations;
        //*for Nextjs you can create an action like following
        // onPayPalSubmit();
    });
};

    return (
        <div className="min-h-screen py-20 px-4">
            <div className="max-w-6xl mx-auto space-y-12">
                <div className="text-center space-y-4">
                    <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                        Purchase Credits
                    </h1>
                    <p className="text-gray-400">Choose the perfect plan for your design needs</p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                    {plans.map((plan, index) => (
                        <motion.div
                            key={plan.credits}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: index * 0.1 }}
                            className={`relative bg-white/5 backdrop-blur-sm rounded-2xl border ${
                                plan.popular ? 'border-purple-500' : 'border-white/10'
                            } p-6 space-y-6`}
                        >
                            {plan.popular && (
                                <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                                    <span className="bg-purple-500 text-xs font-semibold px-3 py-1 rounded-full">
                                        Most Popular
                                    </span>
                                </div>
                            )}


                            <div className="space-y-2">
                                <div className="flex items-baseline gap-2">
                                    <span className="text-4xl font-bold">${plan.price}</span>
                                    <span className="text-gray-400">USD</span>
                                </div>
                                <div className="flex items-center gap-2 text-lg">
                                    <Zap className="w-5 h-5 text-purple-400" />
                                    <span>{plan.credits} Credits</span>
                                </div>
                            </div>

                            <ul className="space-y-3">
                                {plan.features.map((feature, i) => (
                                    <li key={i} className="flex items-center gap-2 text-sm text-gray-300">
                                        <Check className="w-4 h-4 text-purple-400" />
                                        {feature}
                                    </li>
                                ))}
                            </ul>

                            <motion.button
                                onClick={() => handlePlanSelect(plan.credits, plan.price)}
                                className={`w-full py-3 rounded-xl font-medium flex items-center justify-center gap-2 ${
                                    plan.popular
                                        ? 'bg-gradient-to-r from-purple-600 to-blue-600'
                                        : 'bg-white/10 hover:bg-white/20'
                                } transition-colors`}
                                whileHover={{ scale: 1.02 }}
                                whileTap={{ scale: 0.98 }}
                            >
                                <Sparkles className="w-5 h-5" />
                                Select Plan
                            </motion.button>
                        </motion.div>
                    ))}
                </div>

                {/* Modal */}
                {selectedPlan && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 bg-black/90 backdrop-blur-xl z-50 overflow-y-auto"
                    >
                        <div className="min-h-screen px-4 py-12 flex items-center justify-center">
                            <div className="relative bg-white/5 backdrop-blur-sm rounded-2xl border border-white/10 p-8 max-w-md w-full">
                                <button
                                    onClick={() => setSelectedPlan(null)}
                                    className="absolute top-4 right-4 text-gray-400 hover:text-white"
                                >
                                    ✕
                                </button>
                                
                                <h3 className="text-2xl font-bold text-center mb-6">
                                    Complete Purchase
                                </h3>
                                <div className="mb-8 text-center">
                                    <p className="text-lg mb-2">
                                        {selectedPlan.credits} Credits
                                    </p>
                                    <p className="text-3xl font-bold">
                                        ${selectedPlan.price}
                                    </p>
                                </div>
                                
                                <div className="mb-4">
                                <PayPalButtons
                style={{ "layout": "vertical" }}
                disabled={false}
                forceReRender={[{ "layout": "vertical" }]}
                fundingSource={undefined}
                createOrder={createOrder}
                onApprove={onApprove}
            />
                                </div>
                            </div>
                        </div>
                    </motion.div>
                )}

                {/* Add loading overlay */}
                {isProcessing && (
                    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[60] flex items-center justify-center">
                        <div className="text-center space-y-4">
                            <div className="w-16 h-16 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto" />
                            <p className="text-xl">Processing your payment...</p>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}