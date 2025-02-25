import { NextResponse } from "next/server";

export async function POST(
    request: Request,
    { params }: { params: { orderId: string } }
) {
    const orderId = await Promise.resolve(params.orderId);

    try {
        const response = await fetch(
            `https://api.paypal.com/v2/checkout/orders/${orderId}/capture`,
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${process.env.PAYPAL_ACCESS_TOKEN}`,
                },
            }
        );

        const data = await response.json();
        return NextResponse.json(data);
    } catch (error) {
        console.error("Error capturing PayPal order:", error);
        return NextResponse.json(
            { error: "Failed to capture payment" },
            { status: 500 }
        );
    }
} 