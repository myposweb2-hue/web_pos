"""
Enhanced Multi-Format Receipt Generator
Supports: A4 (Professional Invoice), A5 (Compact Invoice), Thermal (POS Terminal)

Features:
- Multiple page sizes and layouts
- Professional business branding with watermarks
- Sri Lankan business styling (LKR currency)
- Corporate-level design with signatures and company stamp space
- Export to PDF, HTML, Print
"""

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, A4, A5, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, mm, cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, KeepTogether
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import ImageReader
from io import BytesIO
import os
from datetime import datetime
from app.models import Setting, Sale, SaleItem
import qrcode
from PIL import Image as PILImage
import traceback

class MultiFormatReceiptGenerator:
    """Generate receipts in multiple formats: A4, A3, Thermal"""
    
    # Format definitions
    FORMATS = {
        'a4': {
            'size': A4,
            'width': 210*mm,      # A4 width
            'height': 297*mm,     # A4 height
            'margins': {'top': 15*mm, 'bottom': 15*mm, 'left': 15*mm, 'right': 15*mm},
            'title_size': 24,
            'subtitle_size': 12,
            'body_size': 10,
            'table_style': 'professional',
        },
        'a5': {
            'size': A5,
            'width': 148*mm,      # A5 width
            'height': 210*mm,     # A5 height
            'margins': {'top': 10*mm, 'bottom': 10*mm, 'left': 10*mm, 'right': 10*mm},
            'title_size': 16,
            'subtitle_size': 10,
            'body_size': 9,
            'table_style': 'compact_invoice',
        },
        'thermal': {
            'size': (80*mm, 300*mm),  # 80mm thermal receipt width, variable height
            'width': 80*mm,
            'height': 300*mm,
            'margins': {'top': 3*mm, 'bottom': 3*mm, 'left': 5*mm, 'right': 5*mm},
            'title_size': 12,
            'subtitle_size': 9,
            'body_size': 8,
            'table_style': 'compact',
        },
    }

    def __init__(self):
        self.styles = getSampleStyleSheet()
        self._setup_styles()

    def _setup_styles(self):
        """Set up professional modern styles with premium appearance"""
        # Professional color palette - modern business design
        self.primary_color = colors.HexColor('#1a1a1a')      # Deep charcoal
        self.accent_dark = colors.HexColor('#2c3e50')        # Professional dark blue
        self.text_dark = colors.HexColor('#2c3e50')          # Professional dark blue
        self.text_medium = colors.HexColor('#34495e')        # Medium blue-gray
        self.text_light = colors.HexColor('#7f8c8d')         # Gray for secondary text
        self.text_lighter = colors.HexColor('#95a5a6')       # Light gray
        self.bg_light = colors.HexColor('#ecf0f1')           # Soft light gray
        self.bg_lighter = colors.HexColor('#e8eef2')         # Very light blue-gray
        self.border_color = colors.HexColor('#bdc3c7')       # Professional border
        self.accent_color = colors.HexColor('#27ae60')       # Green accent
        
        # Modern business name style - clean and elegant
        self.styles.add(ParagraphStyle(
            'BusinessName',
            parent=self.styles['Heading1'],
            fontSize=20,
            fontName='Helvetica-Bold',
            textColor=self.primary_color,
            spaceAfter=6,
            alignment=1,
            leading=24
        ))
        
        # Light gray contact info - minimal visual weight
        self.styles.add(ParagraphStyle(
            'ContactInfo',
            parent=self.styles['Normal'],
            fontSize=8,
            fontName='Helvetica',
            textColor=self.text_lighter,
            spaceAfter=1,
            alignment=1,
            leading=10
        ))
        
        # Subtle section headers
        self.styles.add(ParagraphStyle(
            'SectionHeader',
            parent=self.styles['Normal'],
            fontSize=9,
            fontName='Helvetica-Bold',
            textColor=self.text_dark,
            spaceAfter=3,
            leading=11
        ))
        
        # Modern table header - light background, dark text
        self.styles.add(ParagraphStyle(
            'TableHeader',
            parent=self.styles['Normal'],
            fontSize=9,
            fontName='Helvetica-Bold',
            textColor=self.text_dark,
            backColor=self.bg_lighter,
            spaceAfter=4,
            alignment=1,
            leading=11
        ))
        
        # Invoice number and details style
        self.styles.add(ParagraphStyle(
            'InvoiceDetail',
            parent=self.styles['Normal'],
            fontSize=9,
            fontName='Helvetica',
            textColor=self.text_dark,
            spaceAfter=2,
            leading=11
        ))

    def _get_business_settings(self):
        """Retrieve business settings from database with proper priority"""
        settings = {}
        all_categories = ['receipt', 'general', 'printing']
        
        for category in all_categories:
            cat_settings = Setting.query.filter_by(setting_category=category).all()
            for s in cat_settings:
                if s.setting_key not in settings:
                    settings[s.setting_key] = s.setting_value
        return settings

    def generate_receipt_pdf(self, sale, sale_items, format_type='thermal', business_settings=None):
        """
        Generate receipt PDF in specified format
        
        Args:
            sale: Sale model instance
            sale_items: List of SaleItem instances
            format_type: 'a4', 'a5', or 'thermal'
            business_settings: Dict of business configuration
            
        Returns:
            BytesIO: PDF content
        """
        if business_settings is None:
            business_settings = self._get_business_settings()
        
        if format_type not in self.FORMATS:
            format_type = 'thermal'
        
        format_config = self.FORMATS[format_type]
        
        # Create PDF
        buffer = BytesIO()
        
        if format_type == 'thermal':
            return self._generate_thermal_receipt(buffer, sale, sale_items, business_settings, format_config)
        elif format_type == 'a4':
            return self._generate_a4_receipt(buffer, sale, sale_items, business_settings, format_config)
        elif format_type == 'a5':
            return self._generate_a5_receipt(buffer, sale, sale_items, business_settings, format_config)
    
    def _generate_thermal_receipt(self, buffer, sale, sale_items, business_settings, config):
        """Generate modern minimalist thermal receipt (80mm terminal)"""
        doc = SimpleDocTemplate(
            buffer,
            pagesize=config['size'],
            rightMargin=config['margins']['right'],
            leftMargin=config['margins']['left'],
            topMargin=config['margins']['top'],
            bottomMargin=config['margins']['bottom'],
            title='Modern Receipt'
        )
        
        story = []
        
        # Business name - centered, clean
        business_name = business_settings.get('receipt', {}).get('business_name') or \
                       business_settings.get('general', {}).get('business_name') or 'Company'
        business_phone = business_settings.get('receipt', {}).get('business_phone', '')
        
        story.append(Paragraph(business_name, ParagraphStyle(
            'ThermalHeader',
            parent=self.styles['Normal'],
            fontSize=10,
            fontName='Helvetica-Bold',
            alignment=1,
            textColor=self.primary_color,
            spaceAfter=2
        )))
        
        if business_phone:
            story.append(Paragraph(business_phone, ParagraphStyle(
                'Phone',
                parent=self.styles['Normal'],
                fontSize=6,
                alignment=1,
                textColor=self.text_lighter,
                spaceAfter=2
            )))
        
        # Minimal separator
        story.append(Paragraph("─" * 28, ParagraphStyle(
            'Separator',
            parent=self.styles['Normal'],
            fontSize=7,
            alignment=1,
            textColor=self.border_color,
            spaceAfter=2
        )))
        
        # Receipt details - compact
        receipt_info = [
            [Paragraph("Receipt", ParagraphStyle('Label', parent=self.styles['Normal'], fontSize=6, fontName='Helvetica-Bold', textColor=self.text_dark)),
             Paragraph(str(sale.id), ParagraphStyle('Value', parent=self.styles['Normal'], fontSize=6, textColor=self.text_dark, alignment=2))],
            [Paragraph("Date", ParagraphStyle('Label', parent=self.styles['Normal'], fontSize=6, fontName='Helvetica-Bold', textColor=self.text_dark)),
             Paragraph(sale.date.strftime('%d-%m-%Y'), ParagraphStyle('Value', parent=self.styles['Normal'], fontSize=6, textColor=self.text_dark, alignment=2))],
            [Paragraph("Time", ParagraphStyle('Label', parent=self.styles['Normal'], fontSize=6, fontName='Helvetica-Bold', textColor=self.text_dark)),
             Paragraph(sale.date.strftime('%H:%M'), ParagraphStyle('Value', parent=self.styles['Normal'], fontSize=6, textColor=self.text_dark, alignment=2))],
        ]
        
        receipt_table = Table(receipt_info, colWidths=[26*mm, 44*mm])
        receipt_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 6),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 0),
            ('RIGHTPADDING', (0, 0), (-1, -1), 0),
            ('TOPPADDING', (0, 0), (-1, -1), 1),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ]))
        story.append(receipt_table)
        
        # Cashier
        cashier = getattr(sale, 'cashier', 'Cashier')
        story.append(Paragraph(f"Cashier: {cashier}", ParagraphStyle(
            'Cashier',
            parent=self.styles['Normal'],
            fontSize=6,
            textColor=self.text_dark,
            spaceAfter=2
        )))
        
        # Minimal separator
        story.append(Paragraph("─" * 28, ParagraphStyle(
            'Separator',
            parent=self.styles['Normal'],
            fontSize=7,
            alignment=1,
            textColor=self.border_color,
            spaceAfter=2
        )))
        
        # Customer if available
        if sale.customer:
            story.append(Paragraph(f"{sale.customer}", ParagraphStyle(
                'Customer',
                parent=self.styles['Normal'],
                fontSize=6,
                textColor=self.text_dark,
                spaceAfter=2
            )))
            story.append(Paragraph("─" * 28, ParagraphStyle(
                'Separator',
                parent=self.styles['Normal'],
                fontSize=7,
                alignment=1,
                textColor=self.border_color,
                spaceAfter=2
            )))
        
        # Items - modern compact format
        items_data = [['Item', 'Qty', 'Rate', 'Total']]
        subtotal = 0
        
        for item in sale_items:
            item_total = item.quantity * item.price
            subtotal += item_total
            item_name = (item.product.name[:16] if item.product else 'Product')[:16]
            items_data.append([
                item_name,
                f"{item.quantity:.1f}",
                f"Rs. {item.price:,.0f}",
                f"Rs. {item_total:,.0f}"
            ])
        
        items_table = Table(items_data, colWidths=[24*mm, 10*mm, 13*mm, 13*mm])
        items_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 6),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BACKGROUND', (0, 0), (-1, 0), self.bg_lighter),
            ('TEXTCOLOR', (0, 0), (-1, 0), self.text_dark),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LINEABOVE', (0, 0), (-1, 0), 0.3, self.border_color),
            ('LINEBELOW', (0, 0), (-1, 0), 0.3, self.border_color),
            ('LINEBELOW', (0, -1), (-1, -1), 0.3, self.border_color),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.bg_light]),
            ('LEFTPADDING', (0, 0), (-1, -1), 1),
            ('RIGHTPADDING', (0, 0), (-1, -1), 1),
            ('TOPPADDING', (0, 0), (-1, -1), 1),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ]))
        story.append(items_table)
        
        story.append(Spacer(1, 1.5*mm))
        story.append(Paragraph("─" * 28, ParagraphStyle(
            'Separator',
            parent=self.styles['Normal'],
            fontSize=7,
            alignment=1,
            textColor=self.border_color,
            spaceAfter=2
        )))
        
        # Summary - modern minimal
        discount_amt = getattr(sale, 'discount', 0)
        
        summary_data = [['Subtotal', f"Rs. {subtotal:,.2f}"]]
        if discount_amt > 0:
            summary_data.append(['Discount', f"Rs. {discount_amt:,.2f}"])
        summary_data.append(['Total', f"Rs. {sale.total:,.2f}"])
        
        summary_table = Table(summary_data, colWidths=[34*mm, 16*mm])
        summary_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -2), 6),
            ('FONTSIZE', (0, -1), (-1, -1), 7),
            ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('BACKGROUND', (0, -1), (-1, -1), self.bg_lighter),
            ('LINEBELOW', (0, -2), (-1, -2), 0.3, self.border_color),
            ('LEFTPADDING', (0, 0), (-1, -1), 1),
            ('RIGHTPADDING', (0, 0), (-1, -1), 1),
            ('TOPPADDING', (0, 0), (-1, -1), 1),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ]))
        story.append(summary_table)
        
        story.append(Spacer(1, 2*mm))
        
        # Payment - minimal
        payment = getattr(sale, 'payment', 'Cash')
        story.append(Paragraph(f"<b>{payment}</b>", ParagraphStyle(
            'Payment',
            parent=self.styles['Normal'],
            fontSize=6,
            alignment=1,
            textColor=self.text_dark
        )))
        
        # Change if applicable
        if hasattr(sale, 'balance') and sale.balance and sale.balance > 0:
            story.append(Paragraph(f"Change: Rs. {getattr(sale, 'balance', 0):,.2f}", ParagraphStyle(
                'Change',
                parent=self.styles['Normal'],
                fontSize=6,
                alignment=1,
                textColor=self.text_lighter
            )))
        
        story.append(Spacer(1, 1.5*mm))
        story.append(Paragraph("─" * 28, ParagraphStyle(
            'BottomSeparator',
            parent=self.styles['Normal'],
            fontSize=7,
            alignment=1,
            textColor=self.border_color,
            spaceAfter=2
        )))
        
        # QR Code - optional, minimal
        qr_data = f"Invoice:{sale.id}|Amount:Rs.{sale.total:.2f}|Date:{sale.date.strftime('%Y-%m-%d')}"
        try:
            qr = qrcode.QRCode(version=1, box_size=2, border=1)
            qr.add_data(qr_data)
            qr.make(fit=True)
            qr_img = qr.make_image(fill_color="black", back_color="white")
            
            qr_buffer = BytesIO()
            qr_img.save(qr_buffer, format='PNG')
            qr_buffer.seek(0)
            
            qr_image = Image(qr_buffer, width=35*mm, height=35*mm)
            story.append(Spacer(1, 1*mm))
            story.append(qr_image)
        except:
            pass
        
        story.append(Spacer(1, 2*mm))
        
        # Thank you message - clean
        thank_you = business_settings.get('receipt', {}).get('thank_you_message', 'Thank you!')
        if thank_you:
            story.append(Paragraph(f"<b>{thank_you}</b>", ParagraphStyle(
                'Footer',
                parent=self.styles['Normal'],
                fontSize=7,
                alignment=1,
                textColor=self.text_dark
            )))
        
        # Invoice ID reference - subtle
        story.append(Spacer(1, 1*mm))
        story.append(Paragraph(f"ID: {sale.id}", ParagraphStyle(
            'InvoiceId',
            parent=self.styles['Normal'],
            fontSize=5,
            alignment=1,
            textColor=self.text_lighter
        )))
        
        # Build PDF
        doc.build(story)
        buffer.seek(0)
        return buffer

    def _generate_a4_receipt(self, buffer, sale, sale_items, business_settings, config):
        """Generate professional A4 business invoice"""
        doc = SimpleDocTemplate(
            buffer,
            pagesize=config['size'],
            rightMargin=config['margins']['right'],
            leftMargin=config['margins']['left'],
            topMargin=config['margins']['top'],
            bottomMargin=config['margins']['bottom'],
            title='Professional Invoice'
        )
        
        story = []
        
        # Business information
        business_name = business_settings.get('receipt', {}).get('business_name') or \
                       business_settings.get('general', {}).get('business_name') or 'Company Name'
        business_address = business_settings.get('receipt', {}).get('business_address', '')
        business_phone = business_settings.get('receipt', {}).get('business_phone', '')
        business_email = business_settings.get('receipt', {}).get('business_email', '')
        business_gst = business_settings.get('receipt', {}).get('business_gst', '')
        
        # Professional header with accent bar
        story.append(Paragraph(business_name, ParagraphStyle(
            'ProfessionalHeader',
            parent=self.styles['Heading1'],
            fontSize=24,
            fontName='Helvetica-Bold',
            textColor=self.primary_color,
            alignment=0,
            spaceAfter=2
        )))
        
        # Accent line under company name
        story.append(Paragraph("▌", ParagraphStyle(
            'AccentBar',
            parent=self.styles['Normal'],
            fontSize=16,
            textColor=self.accent_color,
            spaceAfter=8
        )))
        
        # Contact info - clean layout
        contact_items = []
        if business_address:
            contact_items.append(business_address)
        if business_phone:
            contact_items.append(business_phone)
        if business_email:
            contact_items.append(business_email)
        
        if contact_items:
            contact_text = " | ".join(contact_items)
            story.append(Paragraph(contact_text, ParagraphStyle(
                'Contact',
                parent=self.styles['Normal'],
                fontSize=8,
                textColor=self.text_light,
                spaceAfter=12,
                leading=10
            )))
        
        # Top divider
        story.append(Paragraph("─" * 100, ParagraphStyle(
            'DividerTop',
            parent=self.styles['Normal'],
            fontSize=8,
            textColor=self.border_color,
            spaceAfter=12
        )))
        
        # Invoice header section
        invoice_header = [
            [
                Paragraph("<b>INVOICE</b>", ParagraphStyle('InvLabel', parent=self.styles['Normal'], fontSize=9, fontName='Helvetica-Bold', textColor=self.accent_dark)),
                Paragraph("# {0}".format(sale.id), ParagraphStyle('InvValue', parent=self.styles['Normal'], fontSize=10, fontName='Helvetica-Bold', textColor=self.text_dark))
            ],
            [
                Paragraph("Date", ParagraphStyle('DateLabel', parent=self.styles['Normal'], fontSize=8, textColor=self.text_light)),
                Paragraph(sale.date.strftime('%d %B %Y'), ParagraphStyle('DateValue', parent=self.styles['Normal'], fontSize=9, textColor=self.text_dark))
            ],
            [
                Paragraph("Time", ParagraphStyle('TimeLabel', parent=self.styles['Normal'], fontSize=8, textColor=self.text_light)),
                Paragraph(sale.date.strftime('%H:%M:%S'), ParagraphStyle('TimeValue', parent=self.styles['Normal'], fontSize=9, textColor=self.text_dark))
            ]
        ]
        
        invoice_table = Table(invoice_header, colWidths=[90*mm, 70*mm])
        invoice_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 0),
            ('RIGHTPADDING', (0, 0), (-1, -1), 0),
            ('TOPPADDING', (0, 0), (-1, -1), 1),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ]))
        story.append(invoice_table)
        
        story.append(Spacer(1, 10*mm))
        
        # Bill to and From section with background
        bill_from = [
            [
                Paragraph("<b>BILL TO</b>", ParagraphStyle('BillToLabel', parent=self.styles['Normal'], fontSize=8, fontName='Helvetica-Bold', textColor=colors.white, backColor=self.accent_dark)),
                Paragraph("<b>FROM</b>", ParagraphStyle('FromLabel', parent=self.styles['Normal'], fontSize=8, fontName='Helvetica-Bold', textColor=colors.white, backColor=self.accent_dark))
            ],
            [
                Paragraph(sale.customer or 'Walk-in Customer', ParagraphStyle('Customer', parent=self.styles['Normal'], fontSize=9, textColor=self.text_dark, leading=11)),
                Paragraph(business_name, ParagraphStyle('Company', parent=self.styles['Normal'], fontSize=9, textColor=self.text_dark, leading=11))
            ]
        ]
        
        bill_table = Table(bill_from, colWidths=[90*mm, 70*mm])
        bill_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, 0), self.accent_dark),
            ('BACKGROUND', (1, 0), (1, 0), self.accent_dark),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTSIZE', (0, 0), (-1, 0), 8),
            ('FONTSIZE', (0, 1), (-1, 1), 9),
            ('LINEABOVE', (0, 0), (-1, 0), 1, self.accent_dark),
            ('LINEBELOW', (0, -1), (-1, -1), 1, self.border_color),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ]))
        story.append(bill_table)
        
        story.append(Spacer(1, 12*mm))
        
        # Items table - professional styling
        items_data = [['Item No.', 'Description', 'Quantity', 'Unit Price', 'Amount']]
        subtotal = 0
        
        for idx, item in enumerate(sale_items, 1):
            item_total = item.quantity * item.price
            subtotal += item_total
            items_data.append([
                str(idx),
                item.product.name if item.product else 'Product',
                f"{item.quantity:.2f}",
                f"Rs. {item.price:,.2f}",
                f"Rs. {item_total:,.2f}"
            ])
        
        items_table = Table(items_data, colWidths=[14*mm, 88*mm, 20*mm, 28*mm, 30*mm])
        items_table.setStyle(TableStyle([
            # Professional header
            ('BACKGROUND', (0, 0), (-1, 0), self.accent_dark),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 8),
            ('LINEBELOW', (0, 0), (-1, 0), 1, self.accent_dark),
            # Body rows
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('TEXTCOLOR', (0, 1), (-1, -1), self.text_dark),
            # Alignment
            ('ALIGN', (0, 0), (1, -1), 'LEFT'),
            ('ALIGN', (2, 1), (-1, -1), 'RIGHT'),
            # Borders
            ('LINEABOVE', (0, 1), (-1, 1), 0.5, self.border_color),
            ('LINEBELOW', (0, -1), (-1, -1), 1, self.accent_dark),
            # Alternating rows with subtle background
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.bg_light]),
            # Padding
            ('LEFTPADDING', (0, 0), (-1, -1), 6),
            ('RIGHTPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ]))
        story.append(items_table)
        
        story.append(Spacer(1, 10*mm))
        
        # Summary section - prominent and professional
        discount_amt = getattr(sale, 'discount', 0)
        tax_amt = getattr(sale, 'tax', 0)
        
        summary_data = [
            ['Subtotal:', f"Rs. {subtotal:,.2f}"],
        ]
        
        if discount_amt > 0:
            summary_data.append(['Discount:', f"Rs. {discount_amt:,.2f}"])
        
        if tax_amt > 0:
            summary_data.append(['Tax (%):', f"Rs. {tax_amt:,.2f}"])
        
        summary_table = Table(summary_data, colWidths=[100*mm, 60*mm])
        summary_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('TEXTCOLOR', (0, 0), (-1, -1), self.text_dark),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('LINEBELOW', (0, -1), (-1, -1), 0.5, self.border_color),
            ('LEFTPADDING', (0, 0), (-1, -1), 6),
            ('RIGHTPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 3),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ]))
        story.append(summary_table)
        
        story.append(Spacer(1, 6*mm))
        
        # Total section - bold and prominent
        total_table = Table([['TOTAL:', f"Rs. {sale.total:,.2f}"]], colWidths=[100*mm, 60*mm])
        total_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.accent_dark),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('ALIGN', (1, 0), (-1, 0), 'RIGHT'),
            ('LEFTPADDING', (0, 0), (-1, -1), 6),
            ('RIGHTPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        story.append(total_table)
        
        story.append(Spacer(1, 10*mm))
        
        # Payment information - professional
        payment = getattr(sale, 'payment', 'Cash')
        story.append(Paragraph(f"<b>Payment Method:</b> {payment}", ParagraphStyle(
            'Payment',
            parent=self.styles['Normal'],
            fontSize=9,
            textColor=self.text_dark,
            spaceAfter=6
        )))
        
        story.append(Spacer(1, 8*mm))
        
        # Divider before signature
        story.append(Paragraph("─" * 100, ParagraphStyle(
            'DividerSignature',
            parent=self.styles['Normal'],
            fontSize=8,
            textColor=self.border_color,
            spaceAfter=8
        )))
        
        # Signature section
        sig_table = Table([
            [
                Paragraph("_____________________", ParagraphStyle('Sig1', parent=self.styles['Normal'], fontSize=8, alignment=1)),
                Paragraph("_____________________", ParagraphStyle('Sig2', parent=self.styles['Normal'], fontSize=8, alignment=1))
            ],
            [
                Paragraph("Authorized By", ParagraphStyle('SigLabel1', parent=self.styles['Normal'], fontSize=8, textColor=self.text_light, alignment=1)),
                Paragraph("Customer Signature", ParagraphStyle('SigLabel2', parent=self.styles['Normal'], fontSize=8, textColor=self.text_light, alignment=1))
            ]
        ], colWidths=[90*mm, 70*mm])
        sig_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 2),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
        ]))
        story.append(sig_table)
        
        story.append(Spacer(1, 8*mm))
        
        # Footer section
        story.append(Paragraph("─" * 100, ParagraphStyle(
            'DividerFooter',
            parent=self.styles['Normal'],
            fontSize=8,
            textColor=self.border_color,
            spaceAfter=6
        )))
        
        thank_you = business_settings.get('receipt', {}).get('thank_you_message', 'Thank you for your business!')
        story.append(Paragraph(f"<b>{thank_you}</b>", ParagraphStyle(
            'Footer',
            parent=self.styles['Normal'],
            fontSize=9,
            textColor=self.accent_dark,
            alignment=1
        )))
        
        footer_text = business_settings.get('receipt', {}).get('footer_text', 'Please visit us again')
        if footer_text:
            story.append(Paragraph(footer_text, ParagraphStyle(
                'FooterSubtext',
                parent=self.styles['Normal'],
                fontSize=7,
                textColor=self.text_lighter,
                alignment=1
            )))
        
        # Build PDF
        doc.build(story)
        buffer.seek(0)
        return buffer

    def _generate_a5_receipt(self, buffer, sale, sale_items, business_settings, config):
        """Generate professional compact A5 invoice"""
        doc = SimpleDocTemplate(
            buffer,
            pagesize=config['size'],
            rightMargin=config['margins']['right'],
            leftMargin=config['margins']['left'],
            topMargin=config['margins']['top'],
            bottomMargin=config['margins']['bottom'],
            title='Compact Invoice'
        )
        
        story = []
        
        # Business name
        business_name = business_settings.get('receipt', {}).get('business_name') or \
                       business_settings.get('general', {}).get('business_name') or 'Company'
        business_phone = business_settings.get('receipt', {}).get('business_phone', '')
        
        story.append(Paragraph(business_name, ParagraphStyle(
            'CompactHeader',
            parent=self.styles['Heading1'],
            fontSize=16,
            fontName='Helvetica-Bold',
            textColor=self.primary_color,
            alignment=1,
            spaceAfter=2
        )))
        
        # Accent line
        story.append(Paragraph("▌", ParagraphStyle(
            'CompactAccent',
            parent=self.styles['Normal'],
            fontSize=12,
            textColor=self.accent_color,
            alignment=1,
            spaceAfter=4
        )))
        
        if business_phone:
            story.append(Paragraph(business_phone, ParagraphStyle(
                'Phone',
                parent=self.styles['Normal'],
                fontSize=7,
                textColor=self.text_light,
                alignment=1,
                spaceAfter=4
            )))
        
        # Top divider
        story.append(Paragraph("─" * 60, ParagraphStyle(
            'TopDivider',
            parent=self.styles['Normal'],
            fontSize=7,
            textColor=self.border_color,
            alignment=1,
            spaceAfter=4
        )))
        
        # Receipt info - compact
        receipt_info = [
            ['Inv#', str(sale.id), 'Date', sale.date.strftime('%d-%m-%Y')],
            ['Time', sale.date.strftime('%H:%M'), 'By', getattr(sale, 'cashier', 'Staff')]
        ]
        
        receipt_table = Table(receipt_info, colWidths=[14*mm, 16*mm, 14*mm, 16*mm])
        receipt_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 7),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('TEXTCOLOR', (0, 0), (-1, -1), self.text_dark),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('LEFTPADDING', (0, 0), (-1, -1), 1),
            ('RIGHTPADDING', (0, 0), (-1, -1), 1),
            ('TOPPADDING', (0, 0), (-1, -1), 1),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ]))
        story.append(receipt_table)
        
        story.append(Spacer(1, 3*mm))
        
        # Customer
        if sale.customer:
            story.append(Paragraph(f"<b>Customer:</b> {sale.customer}", ParagraphStyle(
                'CustomerInfo',
                parent=self.styles['Normal'],
                fontSize=7,
                textColor=self.text_dark,
                spaceAfter=2
            )))
        
        story.append(Paragraph("─" * 60, ParagraphStyle(
            'MidDivider',
            parent=self.styles['Normal'],
            fontSize=7,
            textColor=self.border_color,
            alignment=1,
            spaceAfter=3
        )))
        
        # Items - compact professional format
        items_data = [['Item', 'Qty', 'Rate', 'Total']]
        subtotal = 0
        
        for item in sale_items:
            item_total = item.quantity * item.price
            subtotal += item_total
            item_name = (item.product.name[:20] if item.product else 'Item')[:20]
            items_data.append([
                item_name,
                f"{item.quantity:.1f}",
                f"Rs. {item.price:,.0f}",
                f"Rs. {item_total:,.0f}"
            ])
        
        items_table = Table(items_data, colWidths=[48*mm, 10*mm, 18*mm, 18*mm])
        items_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.accent_dark),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 7),
            ('FONTSIZE', (0, 1), (-1, -1), 7),
            ('TEXTCOLOR', (0, 1), (-1, -1), self.text_dark),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('LINEBELOW', (0, 0), (-1, 0), 0.5, self.accent_dark),
            ('LINEBELOW', (0, -1), (-1, -1), 0.5, self.accent_dark),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.bg_light]),
            ('LEFTPADDING', (0, 0), (-1, -1), 2),
            ('RIGHTPADDING', (0, 0), (-1, -1), 2),
            ('TOPPADDING', (0, 0), (-1, -1), 2),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ]))
        story.append(items_table)
        
        story.append(Spacer(1, 3*mm))
        
        # Summary - compact
        story.append(Paragraph("─" * 60, ParagraphStyle(
            'SummaryDivider',
            parent=self.styles['Normal'],
            fontSize=7,
            textColor=self.border_color,
            alignment=1,
            spaceAfter=2
        )))
        
        discount_amt = getattr(sale, 'discount', 0)
        
        summary_data = [
            ['Subtotal', f"Rs. {subtotal:,.2f}"],
        ]
        if discount_amt > 0:
            summary_data.append(['Discount', f"Rs. {discount_amt:,.2f}"])
        
        summary_table = Table(summary_data, colWidths=[60*mm, 34*mm])
        summary_table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), 7),
            ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
            ('TEXTCOLOR', (0, 0), (-1, -1), self.text_dark),
            ('LEFTPADDING', (0, 0), (-1, -1), 2),
            ('RIGHTPADDING', (0, 0), (-1, -1), 2),
            ('TOPPADDING', (0, 0), (-1, -1), 1),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ]))
        story.append(summary_table)
        
        # Total - prominent
        total_table = Table([['TOTAL', f"Rs. {sale.total:,.2f}"]], colWidths=[60*mm, 34*mm])
        total_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.accent_dark),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 8),
            ('ALIGN', (1, 0), (-1, 0), 'RIGHT'),
            ('LEFTPADDING', (0, 0), (-1, -1), 2),
            ('RIGHTPADDING', (0, 0), (-1, -1), 2),
            ('TOPPADDING', (0, 0), (-1, -1), 3),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ]))
        story.append(total_table)
        
        story.append(Spacer(1, 3*mm))
        
        # Payment
        payment = getattr(sale, 'payment', 'Cash')
        story.append(Paragraph(f"<b>Payment:</b> {payment}", ParagraphStyle(
            'PaymentInfo',
            parent=self.styles['Normal'],
            fontSize=7,
            textColor=self.text_dark
        )))
        
        story.append(Spacer(1, 2*mm))
        story.append(Paragraph("─" * 60, ParagraphStyle(
            'BottomDivider',
            parent=self.styles['Normal'],
            fontSize=7,
            textColor=self.border_color,
            alignment=1,
            spaceAfter=2
        )))
        
        # Footer - compact
        thank_you = business_settings.get('receipt', {}).get('thank_you_message', 'Thank you!')
        if thank_you:
            story.append(Paragraph(f"<b>{thank_you}</b>", ParagraphStyle(
                'ThankYou',
                parent=self.styles['Normal'],
                fontSize=7,
                textColor=self.accent_dark,
                alignment=1
            )))
        
        # Build PDF
        doc.build(story)
        buffer.seek(0)
        return buffer
