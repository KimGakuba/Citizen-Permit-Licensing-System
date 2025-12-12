# Permit & License Management System - Documentation

## Overview

The **Permit & License Management System** is a comprehensive desktop application built for the Rwanda Government to manage citizen permits, licenses, and related administrative processes. The system provides a modern, user-friendly interface for handling permit applications, processing payments, tracking reviews, and generating reports.

## System Architecture

### Technology Stack
- **Frontend**: Python Tkinter (GUI Framework)
- **Database**: Oracle Database 19c/21c
- **Database Driver**: `oracledb` (Python Oracle Driver)
- **Language**: Python 3.8+

### Database Connection
```python
DB_CONFIG = {
    'user': 'gakuba',
    'password': 'Kim',
    'dsn': 'localhost:1521/thu_27670_kim_permit_db'
}
```

## Installation & Setup

### Prerequisites
1. Python 3.8 or higher
2. Oracle Database (19c or 21c recommended)
3. Oracle Client libraries

### Installation Steps

1. **Install Required Python Package**
   ```bash
   pip install oracledb
   ```

2. **Database Setup**
   - Ensure Oracle Database is running
   - Create the required database schema with all tables, procedures, and functions
   - Update the `DB_CONFIG` dictionary with your credentials

3. **Run the Application**
   ```bash
   python permit_management_system.py
   ```

## Core Features

### 1. Dashboard
- **Real-time Statistics Display**
  - Active Citizens count
  - Total Applications
  - Pending Reviews
  - Active Licenses
  - Total Revenue (RWF)
  - Permit Types
  - Departments
  - Audit Records

### 2. Citizen Management
- **Register New Citizens**
  - Personal information (Name, DOB, National ID)
  - Contact details (Email, Phone, Address)
  - Residency status (Citizen/Resident/Foreigner)
- **Calculate Citizen Age**
- **Check Eligibility** for specific permits

### 3. Application Management
- **Submit New Applications**
  - Select citizen and permit type
  - Set priority level (Low/Normal/High/Urgent)
  - Add application notes
- **View Application Status**
- **Process Payments**
  - Multiple payment methods (Cash, Mobile Money, Bank Transfer)
  - Automatic fee calculation
- **Application Status Summary**

### 4. Permit Types
- View all available permit types
- Display categories, fees, and validity periods
- Estimated processing days
- Active/Inactive status

### 5. Department Management
- View all departments
- Contact information
- Department codes
- Count pending reviews per department
- Performance metrics

### 6. License Management
- View issued licenses
- Track expiration dates
- License status monitoring
- Calculate renewal fees
- Renewal eligibility tracking

### 7. Review Process
- **Add Review Steps**
  - Assign to departments
  - Set reviewer name
  - Add comments
- **Complete Review Steps**
  - Approve/Reject/Request Revision
  - Add decision comments
- Track review progress

### 8. Document Management
- View uploaded documents
- Track document types
- Monitor file sizes
- Verification status

### 9. Holiday Management
- View public holidays
- Track holiday types
- Automatic business day calculations

### 10. Audit Logging
- Complete audit trail of all operations
- Track user actions
- View operation dates and times
- Export capabilities

## Reporting Features

### 1. Monthly Revenue Report
- Filter by year
- View revenue by month
- Application count per month
- Total revenue summary

### 2. Department Performance
- Performance scores by department
- Pending review counts
- Efficiency metrics

### 3. Top Permit Types
- Most requested permit types
- Approval rates
- Average processing fees
- First and last application dates

### 4. Custom Revenue Calculation
- Filter by date range
- Optional permit type filter
- Total revenue calculation

## Export Capabilities

### 1. Audit Logs Export
- **CSV Format**: Structured data export with all audit fields
- **JSON Format**: Machine-readable format for integrations

### 2. Bulk Data Export
- Export all system tables to CSV
- Includes:
  - Citizens
  - Applications
  - Permit Types
  - Departments
  - Licenses
  - Review Steps
  - Documents
  - Holidays
  - Audit Logs

## Business Rules & Validations

### 1. Operation Restrictions
- **Weekend Operations**: Certain operations restricted on weekends
- Automatic checking with `check_operation_allowed()` function

### 2. Bulk Operations
- **Bulk Status Updates**
  - Update multiple applications based on status
  - Age-based filtering (days in current status)
  - Automatic audit trail creation

### 3. Data Validation
- National ID format validation
- Email format validation
- Phone number validation
- Date format validation (YYYY-MM-DD)

## Database Integration

### Stored Procedures Used
- `sp_register_citizen`: Register new citizens
- `sp_submit_application`: Submit permit applications
- `sp_process_payment`: Process application payments
- `sp_add_review_step`: Add review workflow steps
- `sp_complete_review_step`: Complete review steps
- `sp_bulk_update_status`: Bulk update application statuses
- `sp_export_audit_log`: Export audit logs

### Functions Used
- `fn_calculate_citizen_age`: Calculate citizen age
- `fn_validate_eligibility`: Check permit eligibility
- `fn_get_app_status_summary`: Get application summary
- `fn_get_permit_details`: Get permit type details
- `fn_count_pending_reviews`: Count pending reviews
- `fn_calculate_renewal_fee`: Calculate license renewal fees
- `fn_calculate_revenue`: Calculate revenue for date range
- `check_operation_allowed`: Check if operation is allowed

### Package Functions
- `pkg_analytics.get_department_performance`: Department performance metrics
- `pkg_analytics.get_top_permit_types`: Top permit type analysis

## User Interface Components

### Navigation Sidebar
Easy access to all major sections:
- 📊 Dashboard
- 👥 Citizens
- 📄 Applications
- 🎫 Permit Types
- 🏢 Departments
- 📜 Licenses
- ✅ Review Steps
- 📎 Documents
- 📅 Holidays
- 🔍 Audit Logs

### Menu Bar
- **File Menu**: Export options and exit
- **Operations Menu**: Quick access to common operations
- **Reports Menu**: Access to all reports
- **Help Menu**: About information

## Error Handling

### Fixed Issues (Version 2.0)
✅ **DPY-2007 Export Errors**: Proper handling of CLOB and database types  
✅ **ORA-20099 Business Rule Errors**: Enhanced validation  
✅ **ORA-06550 Procedure Errors**: Correct parameter passing  
✅ **Application Number Parsing**: Improved string handling  
✅ **Weekend Operation Restrictions**: Business rule enforcement

### Safe Data Conversion
```python
def safe_convert(val):
    """Handles datetime, CLOB, and NULL values safely"""
```

## Security Features

1. **Database Connection Security**: Parameterized queries to prevent SQL injection
2. **Audit Logging**: Complete trail of all database operations
3. **User Tracking**: Username recorded in audit logs
4. **Status Validation**: Business rule enforcement

## Best Practices

### For Users
1. Always verify citizen information before submitting applications
2. Check eligibility before application submission
3. Process payments promptly after application approval
4. Review audit logs regularly for compliance
5. Export data regularly for backup purposes

### For Administrators
1. Monitor department performance metrics
2. Review pending applications regularly
3. Analyze revenue reports monthly
4. Keep permit types and fees updated
5. Maintain holiday calendar for accurate processing times

## Troubleshooting

### Common Issues

**1. Database Connection Failed**
- Verify Oracle service is running
- Check credentials in `DB_CONFIG`
- Ensure network connectivity to database

**2. Export Fails**
- Ensure write permissions on target directory
- Check disk space availability
- Verify stored procedures exist

**3. Procedure Errors**
- Verify all database objects are created
- Check parameter types match expected values
- Review Oracle error logs

## Future Enhancements

- [ ] Multi-language support (Kinyarwanda, French, English)
- [ ] Email notifications for application status
- [ ] SMS integration for payment confirmations
- [ ] Advanced analytics dashboard
- [ ] Mobile application companion
- [ ] API for third-party integrations
- [ ] Document scanning and OCR integration
- [ ] Biometric authentication support

## Support & Maintenance

### System Requirements
- **Minimum RAM**: 4GB
- **Recommended RAM**: 8GB+
- **Storage**: 100MB for application + database storage
- **Display**: 1400x800 minimum resolution
- **OS**: Windows 10/11, Linux (with Tkinter support)

### Backup Recommendations
1. Daily database backups
2. Weekly full system exports
3. Monthly archive of audit logs
4. Quarterly system health checks

## License & Copyright

**Permit & License Management System**  
Version 2.0 - Complete Error-Free Version  
© 2024 - Rwanda Government  
All rights reserved

---

## Contact & Support

For technical support or feature requests, please contact the system administrator or development team.

**Email**: kimgakuban@gmail.com

**Phone**: 0790016603

**Application Version**: 2.0  
**Last Updated**: December 2024  
**Status**: Production Ready ✅
