"""
Utility functions for validation.
"""
from __future__ import annotations

from typing import Any


def validate_not_empty(value: str) -> str:
    """
    Validate that a string is not empty after stripping whitespace.
    
    Args:
        value: String value to validate
        
    Returns:
        The validated string
        
    Raises:
        ValueError: If the string is empty after stripping
    """
    if not value:
        raise ValueError("Field cannot be empty")
    return value


def strip_whitespace(value: Any) -> str:
    """
    Strip leading and trailing whitespace from a string value.
    
    Args:
        value: Value to strip (should be a string)
        
    Returns:
        Stripped string
    """
    if isinstance(value, str):
        return value.strip()
    return value


def validate_string_length(
    value: str, 
    min_length: int | None = None, 
    max_length: int | None = None,
    field_name: str = "Field"
) -> str:
    """
    Validate string length constraints.
    
    Args:
        value: String to validate
        min_length: Minimum allowed length
        max_length: Maximum allowed length
        field_name: Name of the field for error messages
        
    Returns:
        The validated string
        
    Raises:
        ValueError: If length constraints are violated
    """
    if min_length is not None and len(value) < min_length:
        raise ValueError(f"{field_name} must be at least {min_length} characters long")
    
    if max_length is not None and len(value) > max_length:
        raise ValueError(f"{field_name} must be no more than {max_length} characters long")
    
    return value


def validate_positive_integer(value: int, field_name: str = "Field") -> int:
    """
    Validate that an integer is positive.
    
    Args:
        value: Integer to validate
        field_name: Name of the field for error messages
        
    Returns:
        The validated integer
        
    Raises:
        ValueError: If the integer is not positive
    """
    if value <= 0:
        raise ValueError(f"{field_name} must be a positive integer")
    return value


def validate_non_negative_integer(value: int, field_name: str = "Field") -> int:
    """
    Validate that an integer is non-negative.
    
    Args:
        value: Integer to validate
        field_name: Name of the field for error messages
        
    Returns:
        The validated integer
        
    Raises:
        ValueError: If the integer is negative
    """
    if value < 0:
        raise ValueError(f"{field_name} must be non-negative")
    return value