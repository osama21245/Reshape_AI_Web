import { NextResponse } from "next/server";

export async function POST(
    request: Request,
    context: { params: { orderId: string } }
) {
    const { orderId } = context.params;

    try {
        const response = await fetch(
            `https://api.paypal.com/v2/checkout/orders/${orderId}/capture`,
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${process.env.NEXT_PUBLIC_PAYPAL_CLIENT_ID}`,
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
