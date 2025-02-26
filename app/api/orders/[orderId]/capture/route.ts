import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export async function POST(
    request: NextRequest,
    context: { params?: { orderId?: string } }
) {
    const orderId = context.params?.orderId;

    if (!orderId) {
        return NextResponse.json({ error: "Order ID is missing" }, { status: 400 });
    }

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
