"""
General helper utility functions.
"""
from __future__ import annotations

import logging
from datetime import datetime
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)


def format_datetime(dt: datetime, format_string: str = "%Y-%m-%d %H:%M:%S") -> str:
    """
    Format a datetime object as a string.
    
    Args:
        dt: Datetime object to format
        format_string: Format string for strftime
        
    Returns:
        Formatted datetime string
    """
    return dt.strftime(format_string)


def safe_get(dictionary: Dict[str, Any], key: str, default: Any = None) -> Any:
    """
    Safely get a value from a dictionary.
    
    Args:
        dictionary: Dictionary to get value from
        key: Key to look up
        default: Default value if key not found
        
    Returns:
        Value from dictionary or default
    """
    return dictionary.get(key, default)


def filter_none_values(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Filter out None values from a dictionary.
    
    Args:
        data: Dictionary to filter
        
    Returns:
        Dictionary with None values removed
    """
    return {k: v for k, v in data.items() if v is not None}


def chunk_list(items: List[Any], chunk_size: int) -> List[List[Any]]:
    """
    Split a list into chunks of specified size.
    
    Args:
        items: List to chunk
        chunk_size: Size of each chunk
        
    Returns:
        List of chunks
    """
    if chunk_size <= 0:
        raise ValueError("Chunk size must be positive")
    
    return [items[i:i + chunk_size] for i in range(0, len(items), chunk_size)]


def truncate_string(text: str, max_length: int, suffix: str = "...") -> str:
    """
    Truncate a string to a maximum length with optional suffix.
    
    Args:
        text: String to truncate
        max_length: Maximum length including suffix
        suffix: Suffix to add if truncated
        
    Returns:
        Truncated string
    """
    if len(text) <= max_length:
        return text
    
    if len(suffix) >= max_length:
        return text[:max_length]
    
    return text[:max_length - len(suffix)] + suffix


def log_function_call(func_name: str, args: Optional[Dict[str, Any]] = None) -> None:
    """
    Log a function call with arguments.
    
    Args:
        func_name: Name of the function being called
        args: Arguments passed to the function
    """
    logger.debug(
        f"Function call: {func_name}",
        extra={"function": func_name, "arguments": args or {}}
    )


def create_error_response(message: str, error_code: Optional[str] = None) -> Dict[str, Any]:
    """
    Create a standardized error response dictionary.
    
    Args:
        message: Error message
        error_code: Optional error code
        
    Returns:
        Error response dictionary
    """
    response = {"detail": message}
    if error_code:
        response["error_code"] = error_code
    return response